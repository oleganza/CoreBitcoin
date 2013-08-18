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
#import "NSData+BTC.h"

@interface BTCScriptMachine ()
@end

// We try to match BitcoinQT code as close as possible to avoid subtle incompatibilities.
@implementation BTCScriptMachine {
    
    // Stack contains NSData objects that are interpreted as numbers, bignums, booleans or raw data when needed.
    NSMutableArray* _stack;
    
    // Used in ALTSTACK ops.
    NSMutableArray* _altStack;
    
    // Holds array of @YES and @NO values to keep track of nested OP_IF and OP_ELSE.
    NSMutableArray* _conditionStack;
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
    
    // TODO
    
    return NO;
}






#pragma mark - Stack Utilitites

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
