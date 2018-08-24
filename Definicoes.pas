unit definicoes;

interface

const
  stack_size = 100;
  memory_size = 100;
  variable_memory_start = 8;
  const_variable_size = 0;

  instruction_length = 6;
  parametes_length = 25;
  line_size = 25;
  variable_length = 5;
  label_length = 5;

type
  Ttokens = array[0..15] of array[0..15] of AnsiChar;

  {$SCOPEDENUMS ON}

  TOpcode = (UNDEFINED = 0,
             MOV       = 1,
             ADD       = 3,
             SUB       = 4,
             MUL       = 5,
             JUMP      = 6,
             IF_       = 7,
             EQ        = 8,
             LT        = 9,
             GT        = 10,
             LTEQ      = 11,
             GTEQ      = 12,
             PRINT     = 13,
             READ      = 14,
             ENDIF     = 15,
             END_      = 16);

  intermediate_lang = record
    instruc_nro: integer;
    opcode: Integer;
    parameters: array[0..4] of integer;
  end;

  symbol_table = record
  	variable_name: array[0..variable_length-1] of AnsiChar;
	  address: integer;
  	size: integer;
  end;

  blocks_table = record
 	  name: array[0..label_length-1] of AnsiChar;
	  instr_nro: integer;  // número de instrução após o início
  end;

implementation

end.
