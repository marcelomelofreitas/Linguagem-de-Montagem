unit executor;

interface

uses
  Global,
  stdio,
  stdlib,
  SysUtils;

procedure display_symbol_table;
procedure display_intermediate_table();
procedure display_block_table();
procedure dump_to_file();
procedure exec_program(var memory_array: array of integer; var memory_index: integer);

implementation

procedure display_block_table();
var
  i: Integer;
begin
	printf(^J'--------------- Tabela de Blocos ----------'^J);
	for i := 0 to blocks_index - 1 do
  begin
		printf(^J' Rotulo : %s endereco : %d ', block_tab[i].name, block_tab[i].instr_nro);
  end;

	printf(^J);
end;

procedure display_intermediate_table();
var
  i: Integer;
  j: Integer;
begin
	printf(^J'--------------- Tabela de Instrucoes ----------'^J);

	for i := 0 to intermediate_index - 1 do
  begin
		printf(^J'%d : %d : ', intermediate_table[i].instruc_nro, intermediate_table[i].opcode);
		for j := 0 to Length(intermediate_table[i].parameters) - 1 do
    begin
      if intermediate_table[i].parameters[j] = -1 then
        break;

			printf(' %d', intermediate_table[i].parameters[j]);
    end;
	end;

	printf(^J);
end;

procedure display_symbol_table;
var
  i: Integer;
begin
	printf(^J'--------------- Tabela de Simbolos ----------'^J);

	for i := 0 to symbol_index - 1 do
  begin
		wprintf(PChar(Format('Nome da Variavel : %s, Endereco : %d, Tamanho : %d byte(s)',
                      [symbol_tab[i].variable_name,
                       symbol_tab[i].address, symbol_tab[i].size])+^J));
  end;


end;


procedure dump_to_file();
var
  fp: THandle;
  i, j: Integer;
begin
	fp := fopen('ouput.obj', 'w');
	fprintf(fp, '--------------- Tabela de simbolos ----------'^J);

	for i := 0 to symbol_index - 1 do
  begin
		fprintf(fp, '%s %d %d'^J, symbol_tab[i].variable_name, symbol_tab[i].address, symbol_tab[i].size);
  end;

	fprintf(fp, ^J);

	fprintf(fp, '-------------- Tabela de blocos ----------'^J);
	for i := 0 TO blocks_index - 1 do
		fprintf(fp, '%s %d'^J, block_tab[i].name, block_tab[i].instr_nro);

	fprintf(fp, ^J);

	fprintf(fp, '--------------- Tabela de instrucoes ----------'^J);
	for i := 0 to intermediate_index - 1 do
  begin
    fprintf(fp, '%d %d', intermediate_table[i].instruc_nro, intermediate_table[i].opcode);

		for j := 0 to Length(intermediate_table[i].parameters) - 1 do
    begin
      if intermediate_table[i].parameters[j] = -1 then
        break;

			printf(' %d', intermediate_table[i].parameters[j]);
    end;

		fprintf(fp, ^j);
	end;

	fclose(fp);
end;

function check_condition(operand1: integer; operand2: integer; opcode: Integer): Integer;
begin
  Result := 0;

	case (opcode) of
	  8: begin //Instrucao EQ (=)
       if (operand1 = operand2) then
			    Result := 1;
    end;
	  9: begin // Instrucao LT - Menor que (<)
       if (operand1 < operand2) then
			    Result := 1;
    end;
	  10: begin // Instrucao GT - Maior que ()>)
        if (operand1 > operand2) then
			     Result := 1;
    end;
	  11: begin // Instrucao LTEQ - Menor ou igual (<=)
        if (operand1 <= operand2) then
				  Result := 1;
    end;
	  12: begin // Instrucao GTEQ - Maior ou igual (>=)
        if (operand1 >= operand2) then
				  Result := 1;
    end;
	end;


end;


procedure exec_program(var memory_array: array of integer; var memory_index: integer);
var
  i: Integer;
begin

  i := 0;

  while i  < intermediate_index do  // iterando na tabela de idiomas intermediários
  begin

    case intermediate_table[i].opcode of
        14: begin  // Instrução READ
            printf(^J'Informe a entrada: ');
            scanf('%d', @memory_array[intermediate_table[i].parameters[0]]);
        end;
        01: begin  // Instrução MOV
            memory_array[intermediate_table[i].parameters[0]] := memory_array[intermediate_table[i].parameters[1]];
        end;
        03: begin // Instrução ADD
            memory_array[intermediate_table[i].parameters[0]] := memory_array[intermediate_table[i].parameters[1]] +
                                                                 memory_array[intermediate_table[i].parameters[2]];
        end; // Instrução SUB
        04: begin
            memory_array[intermediate_table[i].parameters[0]] := memory_array[intermediate_table[i].parameters[1]] -
                                                                 memory_array[intermediate_table[i].parameters[2]];
        end; // Instrução PRINT
        13: begin
            printf('%d'^J, memory_array[intermediate_table[i].parameters[0]]);
        end;
        07: begin
				    if (check_condition(memory_array[intermediate_table[i].parameters[0]], memory_array[intermediate_table[i].parameters[1]], intermediate_table[i].parameters[2])=0) then
					  begin
						  i := intermediate_table[i].parameters[3] - 1;  // Instrucao IF
						  continue;
					  end;
        end;
        06: begin // Instrução JUMP ou ELSE
           i := intermediate_table[i].parameters[0] - 1;
           continue;
      end;
    end;

    Inc(i);
  end;

end;

end.
