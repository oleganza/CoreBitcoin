// Oleg Andreev <oleganza@gmail.com>

#import "BTCScriptMachine.h"
#import "BTCScript.h"
#import "BTCOpcode.h"
#import "BTCTransaction.h"
#import "BTCTransactionInput.h"
#import "BTCTransactionOutput.h"
#import "BTCBigNumber.h"
#import "BTCErrors.h"
#import "BTCUnitsAndLimits.h"
#import "BTCData.h"

@interface BTCScriptMachine ()
@end

// We try to match BitcoinQT code as close as possible to avoid subtle incompatibilities.
// The design might not look optimal to everyone, but I prefer to match the behaviour first, then document it well,
// then refactor it with even more documentation for every subtle decision.
// Think of an independent auditor who has to read several sources to check if they are compatible in every little
// decision they make. Proper documentation and cross-references will help this guy a lot.
@implementation BTCScriptMachine {
    
    // Stack contains NSData objects that are interpreted as numbers, bignums, booleans or raw data when needed.
    NSMutableArray* _stack;
    
    // Used in ALTSTACK ops.
    NSMutableArray* _altStack;
    
    // Holds an array of @YES and @NO values to keep track of if/else branches.
    NSMutableArray* _conditionStack;
    
    // Keeps number of executed operations to check for limit.
    NSInteger _opCount;
}

- (id) init
{
    if (self = [super init])
    {
        _inputIndex = 0xFFFFFFFF;
        _blockTimestamp = (uint32_t)[[NSDate date] timeIntervalSince1970];
        [self resetStack];
    }
    return self;
}

- (void) resetStack
{
    _stack = [NSMutableArray array];
    _altStack = [NSMutableArray array];
    _conditionStack = [NSMutableArray array];
    _opCount = 0;
}

- (id) initWithTransaction:(BTCTransaction*)tx inputIndex:(uint32_t)inputIndex
{
    if (!tx) return nil;
    if (inputIndex >= tx.inputs.count) return nil;
    if (self = [self init])
    {
        _transaction = tx;
        _inputIndex = inputIndex;
    }
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    BTCScriptMachine* sm = [[BTCScriptMachine alloc] init];
    sm.transaction = self.transaction;
    sm.inputIndex = self.inputIndex;
    sm.blockTimestamp = self.blockTimestamp;
    sm.verificationFlags = self.verificationFlags;
    sm->_stack = [_stack mutableCopy];
    return sm;
}

- (BOOL) shouldVerifyP2SH
{
    return (_blockTimestamp >= BTC_BIP16_TIMESTAMP);
}

- (BOOL) verifyWithOutputScript:(BTCScript*)outputScript error:(NSError**)errorOut
{
    // Sanity check: transaction and its input should be consistent.
    if (!(self.transaction && self.inputIndex < self.transaction.inputs.count))
    {
        [NSException raise:@"BTCScriptMachineException"  format:@"transaction and valid inputIndex are required for script verification."];
        return NO;
    }
    if (!outputScript)
    {
        [NSException raise:@"BTCScriptMachineException"  format:@"non-nil outputScript is required for script verification."];
        return NO;
    }

    BTCTransactionInput* txInput = self.transaction.inputs[self.inputIndex];
    BTCScript* inputScript = txInput.signatureScript;

    // First step: run the input script which typically places signatures, pubkeys and other static data needed for outputScript.
    if (![self runScript:inputScript error:errorOut])
    {
        return NO;
    }
    
    // Make a copy of the stack if we have P2SH script.
    // We will run deserialized P2SH script on this stack if other verifications succeed.
    BOOL shouldVerifyP2SH = [self shouldVerifyP2SH] && outputScript.isPayToScriptHashScript;
    NSMutableArray* stackForP2SH = shouldVerifyP2SH ? [_stack mutableCopy] : nil;
    
    // Second step: run output script to see that the input satisfies all conditions laid in the output script.
    if (![self runScript:outputScript error:errorOut])
    {
        return NO;
    }
    
    // We need to have something on stack
    if (_stack.count == 0)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Stack is empty after script execution.", @"")}];
        return NO;
    }
    
    // The last value must be YES.
    if ([self boolAtIndex:-1] == NO)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Last item on the stack is boolean NO.", @"")}];
        return NO;
    }
    
    // Additional validation for spend-to-script-hash transactions:
    if (shouldVerifyP2SH)
    {
        // BitcoinQT: scriptSig must be literals-only
        if (![inputScript isPushOnly])
        {
            if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Input script for P2SH spending must be literals-only.", @"")}];
            return NO;
        }
        
        if (stackForP2SH.count == 0)
        {
            // stackCopy cannot be empty here, because if it was the
            // P2SH  HASH <> EQUAL  scriptPubKey would be evaluated with
            // an empty stack and the runScript: above would return false.
            [NSException raise:@"BTCScriptMachineException"  format:@"internal inconsistency: stackForP2SH cannot be empty at this point."];
            return NO;
        }
        
        // Instantiate the script from the last data.
        BTCScript* providedScript = [[BTCScript alloc] initWithData:[stackForP2SH lastObject]];
        
        // Remove it from the stack.
        [stackForP2SH removeObjectAtIndex:stackForP2SH.count - 1];
        
        // Replace current stack with P2SH stack.
        [self resetStack];
        _stack = stackForP2SH;
        
        if (![self runScript:providedScript error:errorOut])
        {
            return NO;
        }
        
        // We need to have something on stack
        if (_stack.count == 0)
        {
            if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Stack is empty after script execution.", @"")}];
            return NO;
        }
        
        // The last value must be YES.
        if ([self boolAtIndex:-1] == NO)
        {
            if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Last item on the stack is boolean NO.", @"")}];
            return NO;
        }
    }
    
    // If nothing failed, validation passed.
    return YES;
}


- (BOOL) runScript:(BTCScript*)script error:(NSError**)errorOut
{
    if (!script)
    {
        [NSException raise:@"BTCScriptMachineException"  format:@"non-nil script is required for -runScript:error: method."];
        return NO;
    }
    
    if (script.data.length > BTC_SCRIPT_MAX_SIZE)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Script binary is too long.", @"")}];
        return NO;
    }

    __block BOOL opFailed = NO;
    [script enumerateOperations:^(NSUInteger opIndex, BTCOpcode opcode, NSData *pushdata, BOOL *stop) {
        
        if (![self executeOpcode:opcode data:pushdata error:errorOut])
        {
            opFailed = YES;
            *stop = YES;
        }
    }];
    
    if (opFailed)
    {
        // Error is already set by executeOpcode, return immediately.
        return NO;
    }
    
    if (_conditionStack.count > 0)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Condition branches unbalanced.", @"")}];
        return NO;
    }
    
    return YES;
}


- (BOOL) executeOpcode:(BTCOpcode)opcode data:(NSData*)pushdata error:(NSError**)errorOut
{
    BOOL shouldExecute = ([_conditionStack indexOfObject:@NO] == NSNotFound);
    
    if (pushdata.length > BTC_MAX_SCRIPT_ELEMENT_SIZE)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Pushdata chunk size is too big.", @"")}];
        return NO;
    }
    
    if (opcode > OP_16 && ++_opCount > 201)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Exceeded the allowed number of operations per script.", @"")}];
        return NO;
    }
    
    // Disabled opcodes
    
    if (opcode == OP_CAT ||
        opcode == OP_SUBSTR ||
        opcode == OP_LEFT ||
        opcode == OP_RIGHT ||
        opcode == OP_INVERT ||
        opcode == OP_AND ||
        opcode == OP_OR ||
        opcode == OP_XOR ||
        opcode == OP_2MUL ||
        opcode == OP_2DIV ||
        opcode == OP_MUL ||
        opcode == OP_DIV ||
        opcode == OP_MOD ||
        opcode == OP_LSHIFT ||
        opcode == OP_RSHIFT)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorScriptError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Attempt to execute a disabled opcode.", @"")}];
        return NO;
    }
    
    if (shouldExecute && pushdata)
    {
        [_stack addObject:pushdata];
    }
    else if (shouldExecute || (OP_IF <= opcode && opcode <= OP_ENDIF))
    {
        switch (opcode)
        {
            //
            // Push value
            //
            case OP_1NEGATE:
            case OP_1:
            case OP_2:
            case OP_3:
            case OP_4:
            case OP_5:
            case OP_6:
            case OP_7:
            case OP_8:
            case OP_9:
            case OP_10:
            case OP_11:
            case OP_12:
            case OP_13:
            case OP_14:
            case OP_15:
            case OP_16:
            {
                // ( -- value)
                BTCBigNumber* bn = [[BTCBigNumber alloc] initWithInt64:(int)opcode - (int)(OP_1 - 1)];
                [_stack addObject:bn.data];
            }
            break;
                
                
            //
            // Control
            //
            case OP_NOP:
            case OP_NOP1: case OP_NOP2: case OP_NOP3: case OP_NOP4: case OP_NOP5:
            case OP_NOP6: case OP_NOP7: case OP_NOP8: case OP_NOP9: case OP_NOP10:
            break;
            
                
            
            // TODO: more operations
                
                
            default:
                return NO;
        }
    }
    
    if (_stack.count + _altStack.count > 1000)
    {
        return NO;
    }
    
    return YES;
}





#pragma mark - Stack Utilities

// 0 is the first item in stack, 1 is the second.
// -1 is the last item, -2 is the pre-last item.
- (NSData*) dataAtIndex:(NSInteger)index
{
    return _stack[index < 0 ? (_stack.count + index) : index];
}

// Returns bignum from pushdata or nil.
- (BTCBigNumber*) bignumberAtIndex:(NSInteger)index
{
    NSData* data = [self dataAtIndex:index];
    if (!data) return nil;
    
    // BitcoinQT throws "CastToBigNum() : overflow"
    if (data.length > 4)
    {
        return nil;
    }

    // Get rid of extra leading zeros like BitcoinQT does:
    // CBigNum(CBigNum(vch).getvch());
    // FIXME: It's a cargo cult here. I haven't checked myself when do these extra zeros appear and whether they really go away. [Oleg]
    BTCBigNumber* bn = [[BTCBigNumber alloc] initWithData:[[BTCBigNumber alloc] initWithData:data].data];
    return bn;
}

- (BOOL) boolAtIndex:(NSInteger)index
{
    NSData* data = [self dataAtIndex:index];
    if (!data) return NO;
    
    NSUInteger len = data.length;
    if (len == 0) return NO;
    
    const unsigned char* bytes = data.bytes;
    for (NSUInteger i = 0; i < len; i++)
    {
        if (bytes[i] != 0)
        {
            // Can be negative zero
            if (i == (len - 1) && bytes[i] == 0x80)
            {
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

@end
