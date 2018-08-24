program asmc;

uses
  cstring,
  stdio,
  Classes,
  Definicoes in 'Definicoes.pas',
  executor in 'executor.pas',
  global in 'global.pas',
  Utils in 'Utils.pas',
  SysUtils;

procedure const_func(var tokens: Ttokens; var memory: array of integer; var memory_index: Integer);
begin
  if (symbol_index = 0) then
  begin
		symbol_tab[symbol_index].address := variable_memory_start;
		strcpy(symbol_tab[symbol_index].variable_name, tokens[1]);
		symbol_tab[symbol_index].size := const_variable_size;
  end
  else
  begin
		strcpy(symbol_tab[symbol_index].variable_name, tokens[1]);
		symbol_tab[symbol_index].size := const_variable_size;
		if (symbol_tab[symbol_index - 1].size <> 0) then
			symbol_tab[symbol_index].address := symbol_tab[symbol_index - 1].address + symbol_tab[symbol_index - 1].size
		else
			symbol_tab[symbol_index].address := symbol_tab[symbol_index - 1].address + 1;
  end;
  inc(symbol_index);
  memory[memory_index] := atoi(tokens[3]);
	inc(memory_index);
end;

procedure data_func(var tokens: Ttokens; var memory: array of integer; var memory_index: Integer);
var
  i, size: Integer;
  variable_name: array[0..variable_length-1] of AnsiChar;
begin
  i := 0;
  size := 0;

  FillChar(variable_name, sizeOf(variable_name), 0);

  if (symbol_index = 0) then
  begin
    symbol_tab[symbol_index].address := variable_memory_start;

    while (tokens[1][i] <> #0) and (tokens[1][i] <> '[') do
    begin
			variable_name[i] := tokens[1][i];
			Inc(i);
    end;

    variable_name[i] := #0;
    strcpy(symbol_tab[symbol_index].variable_name, variable_name); //inserindo o nome da variável

    if (tokens[1][i] = '[') then
    begin
			while (tokens[1][i] <> ']') do
      begin
				size := size * 10 + StrToInt((tokens[1][i]));  //diminuir 48 do valor ansi de um caracter encontra o seu valor em decimal
  			inc(i);
      end;
    end;

    if (size = 0) then
      symbol_tab[symbol_index].size := 1
    else
      symbol_tab[symbol_index].size := size;

    memory_index := symbol_tab[symbol_index].address + symbol_tab[symbol_index].size;
    Inc(symbol_index);
    Exit;
  end
  else
  begin

    while (tokens[1][i] <> #0) and (tokens[1][i] <> '[') do
    begin
			variable_name[i] := tokens[1][i];
			inc(i);
    end;

    variable_name[i] := #0;
    strcpy(symbol_tab[symbol_index].variable_name, variable_name); //inserindo o nome da variável

    if (tokens[1][i] = '[') then
    begin
      inc(i);

      while (tokens[1][i] <> ']') do
      begin
				size := size * 10 + StrToInt((tokens[1][i]));
				inc(i);
      end;
    end;

    if (size = 0) then
      symbol_tab[symbol_index].size := 1
    else
      symbol_tab[symbol_index].size := size;

		if (symbol_tab[symbol_index - 1].size <> 0) then
			symbol_tab[symbol_index].address := symbol_tab[symbol_index - 1].address + symbol_tab[symbol_index - 1].size
		else
			symbol_tab[symbol_index].address := symbol_tab[symbol_index - 1].address + 1;

		memory_index := symbol_tab[symbol_index].address + symbol_tab[symbol_index].size;
		Inc(symbol_index);

		Exit;
  end;
end;


function generate_opcode(instruction: AnsiString): TOpcode;
begin
	if (strcmp(instruction, 'MOV')=0) then
		Result := TOpcode.MOV
	else if (strcmp(instruction, 'ADD')=0) then
		Result := TOpcode.ADD
	else if (strcmp(instruction, 'SUB')=0) then
		Result := TOpcode.SUB
	else if (strcmp(instruction, 'MUL')=0) then
		Result := TOpcode.ADD
	else if (strcmp(instruction, 'JUMP')=0) or (strcmp(instruction, 'ELSE') = 0) then
		Result := TOpcode.JUMP
	else if (strcmp(instruction, 'IF') = 0) then
		Result := TOpcode.IF_
	else if (strcmp(instruction, 'EQ') = 0) then
		Result := TOpcode.EQ
	else if (strcmp(instruction, 'LT') = 0) then
		Result := TOpcode.LT
	else if (strcmp(instruction, 'GT') = 0) then
		Result := TOpcode.GT
	else if (strcmp(instruction, 'LTEQ') = 0) then
		Result := TOpcode.LTEQ
	else if (strcmp(instruction, 'GTEQ') = 0) then
		Result := TOpcode.GTEQ
	else if (strcmp(instruction, 'PRINT') = 0) then
		Result := TOpcode.PRINT
	else if (strcmp(instruction, 'READ') = 0) then
		Result := TOpcode.READ
	else if (strcmp(instruction, 'ENDIF') = 0) then
		Result := TOpcode.ENDIF
	else if (strcmp(instruction, 'END') = 0) then
		Result := TOpcode.END_
  else
    raise Exception.CreateFmt('Instrução invalida: %s', [instruction]);
end;

function GetAddress(const variable_name: AnsiString): Integer;
var
  i, array_index: Integer;
  is_array: Boolean;
  temp: array[0..variable_length-1] of AnsiChar;
begin
  is_array := False;
  array_index := 0;

  if (variable_name[2] = 'X') and (variable_name[1] >= 'A') and (variable_name[1] <= 'H') then  // registrador ou não
  begin
    Exit(Ord(variable_name[1]) - Ord('A'));
  end
  else  //variável => matriz ou variável normal
  begin

    i := Low(variable_name);

    while not (variable_name[i] = #0) do
    begin
      if (variable_name[i] = '[') then  // array
      begin
        sscanf(@variable_name[1], '%[^[]', temp);
        is_array := True;
        Inc(i);

				while not (variable_name[i] = ']') do
        begin
					array_index := array_index * 10 + StrToInt(variable_name[i]);
					inc(i);
				end;
				break;
      end;
 		  inc(i);
    end;

		if (is_array) then
			sscanf(@variable_name[1], '%[^*]', temp);
  end;

	strcpy(PAnsiChar(@variable_name[1]), temp);
	for i := 0 to symbol_index -1 do
  begin
		if (strcmp(symbol_tab[i].variable_name, variable_name) = 0) then
		begin
			if (is_array) then
				Exit(symbol_tab[i].address + array_index)
			else
				Exit(symbol_tab[i].address);
		end;
	end;

	Result := -1; // variável não presente
end;

procedure read_func(param: AnsiString; instruction_nro: Integer);
begin
	intermediate_table[intermediate_index].parameters[0] := getAddress(param);
	intermediate_table[intermediate_index].parameters[1] := -1;
	intermediate_table[intermediate_index].opcode := 14;
	intermediate_table[intermediate_index].instruc_nro := instruction_nro;
	inc(intermediate_index);
end;


procedure mov_func(param: AnsiString; instruction_nro: Integer);
var
  dest: array[0..variable_length-1] of AnsiChar;
  src: array[0..variable_length-1] of AnsiChar;
  token: AnsiString;
begin
  token := strtok(param, ', ');
  strcpy(dest, token);

  token := strtok(nil, ', ');
  strcpy(src, token);

  // tabela de instruções
  intermediate_table[intermediate_index].instruc_nro := instruction_nro;

  if (dest[1] = 'X') and (dest[0] >= 'A') and (dest[0] <= 'H') then // Destinatario é um registrador
  begin
		intermediate_table[intermediate_index].opcode := 2;
		intermediate_table[intermediate_index].parameters[0] := getAddress(dest);
		intermediate_table[intermediate_index].parameters[1] := getAddress(src);
		intermediate_table[intermediate_index].parameters[2] := -1;  // to run the for loop
  end;
end;

procedure jump_func(param: AnsiString; instruction_nro: Integer);
var
  i: Integer;
begin
	intermediate_table[intermediate_index].instruc_nro := instruction_nro;
	intermediate_table[intermediate_index].opcode := 6;

	for i := 0 to blocks_index - 1 do
  begin
		if (strcmp(block_tab[i].name, param) = 0) then
    begin
			intermediate_table[intermediate_index].parameters[0] := block_tab[i].instr_nro;
			intermediate_table[intermediate_index].parameters[1] := -1;
			break;
		end;
	end;

	inc(intermediate_index);
end;


procedure else_func(instruction_nro: Integer; var stack: array of Integer; var top: Integer);
begin
	intermediate_table[intermediate_index].instruc_nro := instruction_nro;
	intermediate_table[intermediate_index].opcode := 6;
	intermediate_table[intermediate_index].parameters[0] := -2;
	intermediate_table[intermediate_index].parameters[1] := -1;
	// empurre para a pilha
  inc(top);
	stack[top] := instruction_nro;
	inc(intermediate_index);
end;


procedure if_func(param: AnsiString; instruction_nro: Integer; var stack: array of Integer; var top: Integer);
var
  operand1: array[0..variable_length-1] of AnsiChar;
  operand2: array[0..variable_length-1] of AnsiChar;
  oper: array[0..6] of AnsiChar;
begin
	//* pega o primeiro token
	sscanf(@param[1], '%s %s %s', operand1, oper, operand2);
//   IF CX EQ DX THEN
	intermediate_table[intermediate_index].instruc_nro := instruction_nro;
	intermediate_table[intermediate_index].opcode := 7;
	intermediate_table[intermediate_index].parameters[0] := getAddress(operand1);
	intermediate_table[intermediate_index].parameters[1] := getAddress(operand2);
	intermediate_table[intermediate_index].parameters[2] := Ord(generate_opcode(oper));
	intermediate_table[intermediate_index].parameters[3] := -2;
	intermediate_table[intermediate_index].parameters[4] := -1;
	// empurre para a pilha
  inc(top);
	stack[top] := instruction_nro;
	inc(intermediate_index);
end;


procedure endif_func(var instruction_nro: Integer; var stack: array of Integer; var top: Integer);
var
  poped_value: Integer;
  i: Integer;
begin
  poped_value := stack[top];
  dec(top);

  i := intermediate_index;

  while (intermediate_table[i].instruc_nro <> poped_value) do
  begin
    Dec(i);
  end;

  Inc(i);
  intermediate_table[i].parameters[0] := instruction_nro;
//  poped_value := stack[top];
  dec(top);

  Dec(instruction_nro);
end;

procedure print_func(param: AnsiString; instruction_nro: Integer);
begin
	intermediate_table[intermediate_index].parameters[0] := getAddress(param);
	intermediate_table[intermediate_index].parameters[1] := -1;
	intermediate_table[intermediate_index].opcode := 13;
	intermediate_table[intermediate_index].instruc_nro := instruction_nro;
	inc(intermediate_index);
end;

procedure bianryOperations_func(opcode: TOpcode; param: AnsiString; instruction_nro: Integer);
var
  dest: array[0..variable_length-1] of AnsiChar;
  operand1: array[0..variable_length-1] of AnsiChar;
  operand2: array[0..variable_length-1] of AnsiChar;
  token: AnsiString;
begin
  token := strtok(param, ', ');
  strcpy(dest, token);

	token := strtok(nil, ', ');
	strcpy(operand1, token);

	token := strtok(nil, ', ');
	strcpy(operand2, token);

	intermediate_table[intermediate_index].opcode := Ord(opcode);
	intermediate_table[intermediate_index].instruc_nro := instruction_nro;
	intermediate_table[intermediate_index].parameters[0] := getAddress(dest);
	intermediate_table[intermediate_index].parameters[1] := getAddress(operand1);
	intermediate_table[intermediate_index].parameters[2] := getAddress(operand2);
	intermediate_table[intermediate_index].parameters[3] := -1;
	inc(intermediate_index);
end;

procedure Start;
var
	stack: array[0..stack_size-1] of Integer;
  top: Integer;
	memory_array: array[0..memory_size-1] of Integer;
	memory_index: integer;
  i: Integer;
  line: Array[0..line_size-1] of AnsiChar;
  tokens: Ttokens;
  buffer: array [0..9] of AnsiChar;
  row, buffer_index: Integer;
  SourceFile: THandle;
  instruction: array[0..instruction_length-1] of AnsiChar;
  param: array[0..parametes_length-1] of AnsiChar;
  opcode: TOpcode;
  instruction_nro: Integer;
begin
  top := -1;
	memory_index := variable_memory_start - 1 ;  // 0 a 7 já estão reservados

  FillChar(tokens, sizeOf(tokens), 0);
  FillChar(buffer, sizeOf(buffer), 0);
  FillChar(memory_array, sizeOf(memory_array), 0);
  FillChar(stack, sizeOf(stack), 0);

  SourceFile := fopen('teste.asm', 'r');

  if SourceFile = 0 then
    raise Exception.Create('não foi possivel abrir o arquivo fontes');
  

  // antes de start
  while fgets(line, line_size, SourceFile) <> #0  do
  begin
		if (strcmp(line, 'START:'#10) = 0) then
			Break;

    row := 0;
    buffer_index := 0;

    // gerando tokens
    i := 0;
    while True do
    begin
      if line[i] = #0 then  //fim da linha
        Break;

      if (line[i] = ' ') or (line[i] = #10) then  //novo token ou final da linha
      begin
        buffer[buffer_index] := #0;
        buffer_index := 0;
        strcpy(tokens[row], buffer);
        inc(row);

        FillChar(buffer, sizeOf(buffer), 0);
      end
      else
      begin
        buffer[buffer_index] := line[i];
        inc(buffer_index);
      end;

      inc(i);
    end;

    // gerando tokens //
    if strcmp(tokens[0], 'DATA') = 0 then
    begin
      data_func(tokens, memory_array, memory_index);
    end
		else if strcmp(tokens[0], 'CONST') = 0 then
			const_func(tokens, memory_array, memory_index);
  end;

  display_symbol_table();

  //apos start
//  opcode := TOpcode.UNDEFINED;
  instruction_nro := 0;

  while not feof(SourceFile) do
  begin
    inc(instruction_nro);
    fscanf(SourceFile, PAnsiChar('%[^'#10']'#10), line);

    if (line[cstring.strlen(line) - 1] = ':') then
    begin
      line[cstring.strlen(line) - 1] := #0;
      block_tab[blocks_index].instr_nro := instruction_nro;
      strcpy(block_tab[blocks_index].name, line);
      Inc(blocks_index);
      dec(instruction_nro);
      continue;
    end;

    sscanf(line, '%s %[^*]', instruction, param);
//    printf('Instrucao  %d  : %s %s'#10, instruction_nro, instruction, param);

    opcode := generate_opcode(instruction);
    case (opcode) of
      TOpcode.MOV: mov_func(param, instruction_nro);
      TOpcode.READ: read_func(param, instruction_nro);
      TOpcode.ADD: bianryOperations_func(opcode, param, instruction_nro);
      TOpcode.SUB: bianryOperations_func(opcode, param, instruction_nro);
      TOpcode.PRINT: print_func(param, instruction_nro);
      TOpcode.IF_: if_func(param, instruction_nro, stack, top);
      TOpcode.JUMP: if strcmp(instruction, 'ELSE') = 0 then
                      else_func(instruction_nro, stack, top)
                    else
                      jump_func(param, instruction_nro);
      TOpcode.ENDIF: endif_func(instruction_nro, stack, top);
      TOpcode.END_: Break;
    else
      raise Exception.Create('opcode não implementado: ' + TEnum<TOpcode>.ToString(opcode) );
    end;
  end;

//ending:
	display_intermediate_table();
	display_block_table();
  fclose(SourceFile);

	// cria o arquivo
	dump_to_file();


	// executa o programa //
  exec_program(memory_array, memory_index);
	getch();

end;

begin
  Start();
end.
