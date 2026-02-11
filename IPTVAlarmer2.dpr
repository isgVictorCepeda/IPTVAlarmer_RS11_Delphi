program IPTVAlarmer2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils,
  Idtcpclient;

var
  ini    : TIniFile;
  tmpStr : String;

  sAlarmNumber : String;
  sAlarmState  : String;
  sAlarmSignal : String;
  TCPClient    : TIdTCPClient;


begin
  if ParamCount < 2 then
    begin
      Writeln('No parameters provided. /help is a valid parameter');
      exit;
    end;

  try
    ini    := TIniFile(TPath.GetHomePath() + TPath.DirectorySeparatorChar + 'IPTVAlarm.ini');
    tmpStr := ParamStr(1);
    if LowerCase(tmpStr) = '/setup' then
         begin
            try
               ini.WriteString('GLOBAL', 'Host', ParamStr(2));
               ini.WriteString('GLOBAL', 'Port', ParamStr(3));
               Writeln('Settings saved');
            except
              on E: Exception do
                Writeln('Failed to save settings');
            end;
         end
    else if (LowerCase(tmpStr) = '/?') or (LowerCase(tmpStr) = '/help') then
        begin
            Writeln('Parametrar f�r IPTV Alarmer:');
            Writeln('IPTVAlarmer [/setup [host] [port]] ');
            Writeln('IPTVAlarmer [larmid] [larmstatus]');
            Writeln('IPTVAlarmer [/?] [/help]\n');
            Writeln('   /setup      Skapar IPTVAlarmer.ini med inst�llningar');
            Writeln('   host        IP-nummer till v�rddatorn som k�r IPTV');
            Writeln('   port        Portnummer som IPTV lyssnar p�');
            Writeln('   larmid      ID f�r IPV-larmh�ndelsen (VIDOS Alarm i Integral), ');
            Writeln('               ett v�rde mellan 10000 och 20000.');
            Writeln('   larmstatus  0 Larmfritt       1 Larmar');
            Writeln('   /?  /help   Visar denna sidan');
        end
    else
       begin
            sAlarmSignal := '';
            TCPClient    := TIdTCPClient(NIL);

            try
               sAlarmNumber := ParamStr(1);
               sAlarmState  := ParamStr(2);
               if ParamCount >= 4 then
                  sAlarmSignal := ParamStr(3);

               TCPClient.Host := ini.ReadString ('GLOBAL', 'Host', '');
               TCPClient.Port := ini.ReadInteger('GLOBAL', 'Port', 0);
            except

            end;

            try
                TCPClient.Connect;
            except
              on E: Exception do
                begin
                  Writeln('Failed to connect:');
                  Writeln(E.message);
                  Writeln;
                end;
            end;

            if TCPClient.Connected then
               begin
                 Writeln('Connect success');

                 try

                    if sAlarmSignal <> '' then
                       TCPClient.IOHandler.WriteLn(Format('%s %s %s', [sAlarmNumber, sAlarmState, sAlarmSignal]))
                    else
                       TCPClient.IOHandler.WriteLn(Format('%s %s', [sAlarmNumber, sAlarmState]));
                    Writeln('Write to connection success');

                 except
                  on E: Exception do
                    begin
                      Writeln('Failed to write to connection:');
                      Writeln(E.message);
                      Writeln;
                    end;
                 end;

                 TCPClient.Disconnect;
                 Writeln('Disconnect success');
               end;
       end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

