
There is no single fully reversible textual format for scripts. 

BitcoinQT uses this format in its unit tests:

   -?[0-9]+ is interpreted as int64. If it's from -1 to 16, interprets as "OP_<N>", otherwise pushes bignum data.
   '[^']*' is interpreted as ASCII string 
   0x[0-9a-fA-F]+ is interpreted as a raw binary to be inserted in script (not just data)
   (OP_)?<opcode name> is replaced by an opcode byte.

