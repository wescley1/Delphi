unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  IdGlobal, IdHashSHA, IdHMAC, IdHMACSHA1, IdSSLOpenSSL, SynCrypto,
  Jsons, JsonsUtilsEx,HttpConnection, RestClient, Grids, ValEdit, Menus,
  ComCtrls, UDetalhePedido, UDetalheProduto;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    Button2: TButton;
    Edit2: TEdit;
    Edit4: TEdit;
    RestClient1: TRestClient;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Edit5: TEdit;
    Button3: TButton;
    Label4: TLabel;
    Label6: TLabel;
    Edit6: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Edit3: TEdit;
    Edit1: TEdit;
    Button4: TButton;
    Label9: TLabel;
    Edit7: TEdit;
    GroupBox3: TGroupBox;
    Button5: TButton;
    ListBox1: TListBox;
    Edit8: TEdit;
    Label10: TLabel;
    Button6: TButton;
    OpenDialog1: TOpenDialog;
    CheckBox1: TCheckBox;
    GroupBox4: TGroupBox;
    ComboBox1: TComboBox;
    Label11: TLabel;
    Button7: TButton;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label12: TLabel;
    ListBox2: TListBox;
    ComboBox2: TComboBox;
    Label13: TLabel;
    Button8: TButton;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    //function CalculateHMACSHA256(const value, salt: String): String;
    function CalculateHMACSHA256(const value, sKey: String): String;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }

  end;

var
  Form1: TForm1;
  gRefreshToken, gAcessToken : string;

implementation

uses DateUtils;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
 host, path, redirect_url, timest, partner_id, partner_key,
 sign, base_string : string;


begin

//host := 'https://partner.test-stable.shopeemobile.com';
host := 'https://openplatform.test-stable.shopee.cn';
path := '/api/v2/shop/auth_partner';
redirect_url := 'http://www.polinfoinformatica.com.br';
partner_id := '1077689';
timest := IntToStr(DateTimeToUnix(Now)+10800);
partner_key := '7569704d6e5a616e665848427351786c79537769506e674c4241416a59576d72';
base_string := Format('%s%s%s',[partner_id,path,timest]);
sign := CalculateHMACSHA256(base_string,partner_key);
Memo1.Lines.Clear();
Memo1.Lines.Add(timest);
Memo1.Lines.Add(sign);
Memo1.Lines.Add(Format('Link de autorização: %s%s?partner_id=%s&timestamp=%s&sign=%s&redirect=%s',[host,path,partner_id,timest,sign,redirect_url]));

end;

procedure TForm1.Button2Click(Sender: TObject);
var
 host, path, redirect_url, timest, res, partner_id, partner_key,
 sign, url, base_string, lJsonString, m_resource, error : string;
 auth_code, body : string;
 lJson: TJson;
 _jsonarray01: TJSONArray;
 _jsonobj01: TJSONObject;
 myFile : TextFile;


begin
  Screen.Cursor := crHourGlass;
  Memo1.Lines.Clear();

  host := 'https://partner.test-stable.shopeemobile.com';
  path := '/api/v2/auth/token/get';
  //redirect_url := 'http://www.polinfoinformatica.com.br';
  partner_id := '1077689';
  timest := IntToStr(DateTimeToUnix(Now)+10800);
  partner_key := '7569704d6e5a616e665848427351786c79537769506e674c4241416a59576d72';
  base_string := Format('%s%s%s',[partner_id,path,timest]);
  sign := CalculateHMACSHA256(base_string,partner_key);
  m_resource := Format('%s%s?partner_id=%s&timestamp=%s&sign=%s',[host,path,partner_id,timest,sign]);



  if Edit2.text = '' then
  begin
    gRefreshToken := '4c6b767963414d4a7859456970415779';
  end
  else
  begin
    gRefreshToken := Edit2.Text;
  end;

  body := Format('{"code": "%s", "shop_id": 96276, "partner_id": %s}',[Edit2.Text,partner_id]);




  try
        lJsonString := RestClient1
                 .Resource( m_resource )
                 .Header('Content-Type', 'application/json')
                 .Post(body);
    except
      on E: Exception do
      begin
        if E is EHTTPError then
          if EHTTPError(E).ErrorCode = RestClient1.ResponseCode then
          begin
           if lJson.IsJsonObject(lJsonString) then
           begin
             lJson := TJson.Create;
             lJson.Parse(lJsonString);
             error := lJson.Values['message'].AsString;
             FreeAndNil(lJson);
             ShowMessage( UpperCase(IntToStr(RestClient1.ResponseCode) + ' - ' + error));
           end;
          end;
        Screen.Cursor := crDefault;
        //m_vlcontinua  := False;
      end;
    end;

  if lJson.IsJsonObject(lJsonString) then
  begin
      lJson := TJson.Create;
      lJson.Parse(lJsonString);

      _jsonobj01   := lJson.JsonObject;

      if _jsonobj01.Values['error'].AsString <> '' then
      begin
        Memo1.Lines.Add('Error message: '+_jsonobj01.Values['message'].AsString);
        //Edit4.text := _jsonobj01.Values['message'].AsString;
      end
      else
      begin
        AssignFile(myFile, 'infos.txt');
        ReWrite(myFile);

        Write(myFile,Format('{"refresh_token":"%s","access_token":"%s","timestamp":"%s","expire_in":"%s"}',
          [_jsonobj01.Values['refresh_token'].AsString,_jsonobj01.Values['access_token'].AsString,timest,_jsonobj01.Values['expire_in'].AsString]));

        Reset(myFile);

        Edit4.Text := _jsonobj01.Values['access_token'].AsString;
        Edit5.Text := _jsonobj01.Values['refresh_token'].AsString;
        Edit6.Text := DateTimeToStr(UnixToDateTime(StrToInt(timest) + StrToInt(_jsonobj01.Values['expire_in'].AsString)));

        CloseFile(myFile);

      end;
  end;


  Memo1.Lines.Add('Timestamp: '+timest);
  Memo1.Lines.Add('Sign: '+sign);
  Memo1.Lines.Add(Format('Link de de consulta: %s',[m_resource]));


  Screen.Cursor := crDefault;
end;

function TForm1.CalculateHMACSHA256(const value, sKey: String): String;
var
  sha256Digest: TSHA256Digest;
begin
  try
    HMAC_SHA256(UTF8Encode(skey),UTF8Encode(value),sha256Digest);
    Result:=UpperCase(SHA256DigestToString(sha256Digest));
  except
    Result:='';
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  lJson: TJson;
  _jsonarray01: TJSONArray;
  _jsonobj01: TJSONObject;
  myFile : TextFile;
  dlg: TOpenDialog;
  text,lJsonString, timest, arquivoSelecionado   : string;
begin
  Memo1.Lines.Clear();

  arquivoSelecionado := '';
  dlg := TOpenDialog.Create(nil);

  if CheckBox1.Checked then
  begin
    try
      dlg.InitialDir := 'D:\';
      dlg.Filter := 'All files (*.*)|*.*';
      if dlg.Execute() then
        arquivoSelecionado := dlg.FileName;
    finally
      dlg.Free;
    end;
  end
  else arquivoSelecionado := 'infos.txt';





  AssignFile(myFile, arquivoSelecionado);
{  ReWrite(myFile);

  WriteLn(myFile, '"refresh_token":"734b73534450695753624969746d5357",');
  WriteLn(myFile, '"access_token": "62765a4e597a70566279514573757a48"');}

  Reset(myFile);

  // Display the file contents
{  while not Eof(myFile) do
  begin
    Read(myFile, lJsonString);
    Memo1.Lines.Add(lJsonString);
  end;}
  Read(myFile, lJsonString);
  Memo1.Lines.Add(lJsonString);


  if lJson.IsJsonObject(lJsonString) then
  begin
    lJson := TJson.Create;
    lJson.Parse(lJsonString);

    _jsonobj01   := lJson.JsonObject;

    timest := _jsonobj01.Values['timestamp'].AsString;


    Edit4.Text := _jsonobj01.Values['access_token'].AsString;
    Edit5.Text := _jsonobj01.Values['refresh_token'].AsString;
    Edit6.Text := DateTimeToStr(UnixToDateTime(StrToInt(timest) + StrToInt(_jsonobj01.Values['expire_in'].AsString)));


  end;



  CloseFile(myFile);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
 host, path, redirect_url, timest, res, partner_id, partner_key,
 sign, url, base_string, lJsonString, m_resource, error : string;
 auth_code, body : string;
 lJson: TJson;
 _jsonarray01: TJSONArray;
 _jsonobj01: TJSONObject;
 myFile1 : TextFile;


begin
  Screen.Cursor := crHourGlass;
  Memo1.Lines.Clear();

  host := 'https://partner.test-stable.shopeemobile.com';
  path := '/api/v2/auth/access_token/get';
  //redirect_url := 'http://www.polinfoinformatica.com.br';
  partner_id := '1077689';
  timest := IntToStr(DateTimeToUnix(Now)+10800);
  partner_key := '7569704d6e5a616e665848427351786c79537769506e674c4241416a59576d72';
  base_string := Format('%s%s%s',[partner_id,path,timest]);
  sign := CalculateHMACSHA256(base_string,partner_key);
  m_resource := Format('%s%s?partner_id=%s&timestamp=%s&sign=%s',[host,path,partner_id,timest,sign]);



  if Edit2.text = '' then
  begin
    gRefreshToken := '4c6b767963414d4a7859456970415779';
  end
  else
  begin
    gRefreshToken := Edit2.Text;
  end;

  body := Format('{"refresh_token": "%s", "shop_id": 96276, "partner_id": %s}',[Edit5.Text,partner_id]);




  try
        lJsonString := RestClient1
                 .Resource( m_resource )
                 .Header('Content-Type', 'application/json')
                 .Post(body);
    except
      on E: Exception do
      begin
        if E is EHTTPError then
          if EHTTPError(E).ErrorCode = RestClient1.ResponseCode then
          begin
           if lJson.IsJsonObject(lJsonString) then
           begin
             lJson := TJson.Create;
             lJson.Parse(lJsonString);
             error := lJson.Values['message'].AsString;
             FreeAndNil(lJson);
             ShowMessage( UpperCase(IntToStr(RestClient1.ResponseCode) + ' - ' + error));
           end;
          end;
        Screen.Cursor := crDefault;
        //m_vlcontinua  := False;
      end;
    end;

  if lJson.IsJsonObject(lJsonString) then
  begin
      lJson := TJson.Create;
      lJson.Parse(lJsonString);

      _jsonobj01   := lJson.JsonObject;

      if _jsonobj01.Values['error'].AsString <> '' then
      begin
        Memo1.Lines.Add('Error message: '+_jsonobj01.Values['message'].AsString);
        //Edit4.text := _jsonobj01.Values['message'].AsString;
      end
      else
      begin
        AssignFile(myFile1, 'infos.txt');
        ReWrite(myFile1);

        Write(myFile1,Format('{"refresh_token":"%s","access_token":"%s","timestamp":"%s","expire_in":"%s"}',
          [_jsonobj01.Values['refresh_token'].AsString,_jsonobj01.Values['access_token'].AsString,timest,_jsonobj01.Values['expire_in'].AsString]));

        Reset(myFile1);

        Edit7.Text := _jsonobj01.Values['access_token'].AsString;
        Edit1.Text := _jsonobj01.Values['refresh_token'].AsString;
        Edit3.Text := DateTimeToStr(UnixToDateTime(StrToInt(timest) + StrToInt(_jsonobj01.Values['expire_in'].AsString)));

        CloseFile(myFile1);

      end;
  end;


  Memo1.Lines.Add('Timestamp: '+timest);
  Memo1.Lines.Add('Sign: '+sign);
  Memo1.Lines.Add(Format('Link de de consulta: %s',[m_resource]));


  Screen.Cursor := crDefault;

end;

procedure TForm1.Button5Click(Sender: TObject);
var
 host, path, redirect_url, timest, res, partner_id, partner_key,
 sign, url, base_string, lJsonString, m_resource, error, shop_id,
 access_token, item_id_list, lJsonString02, m_resource02, path02,
 timest02, base_string02, sign02, descricao : string;
 auth_code, body : string;
 lJson: TJson;
 _jsonarray01,_jsonarray02: TJSONArray;
 _jsonobj01,_jsonobj02: TJSONObject;
 i : integer;
 myFile : TextFile;


begin
  Screen.Cursor := crHourGlass;
  Memo1.Lines.Clear();

  AssignFile(myFile, 'infos.txt');

  Reset(myFile);

  Read(myFile, lJsonString);
  //Memo1.Lines.Add(lJsonString);


  if lJson.IsJsonObject(lJsonString) then
  begin
    lJson := TJson.Create;
    lJson.Parse(lJsonString);

    _jsonobj01   := lJson.JsonObject;

    access_token := _jsonobj01.Values['access_token'].AsString;

  end;
  CloseFile(myFile);


  host := 'https://partner.test-stable.shopeemobile.com';
  path := '/api/v2/product/get_item_list';
  //redirect_url := 'http://www.polinfoinformatica.com.br';
  partner_id := '1077689';
  shop_id := '96276';
  timest := IntToStr(DateTimeToUnix(Now)+10800);
  partner_key := '7569704d6e5a616e665848427351786c79537769506e674c4241416a59576d72';
  base_string := Format('%s%s%s%s%s',[partner_id,path,timest,access_token,shop_id]);
  sign := CalculateHMACSHA256(base_string,partner_key);
  m_resource := Format('%s%s?partner_id=%s&timestamp=%s&access_token=%s&shop_id=%s&sign=%s&page_size=100&item_status=NORMAL&offset=0',[host,path,partner_id,timest,access_token,shop_id,sign]);







  try
    lJsonString := RestClient1
                 .Resource( m_resource )
                 .Header('Content-Type', 'application/json')
                 .Get;
    except
      on E: Exception do
      begin
        if E is EHTTPError then
          if EHTTPError(E).ErrorCode = RestClient1.ResponseCode then
          begin
           if lJson.IsJsonObject(lJsonString) then
           begin
             lJson := TJson.Create;
             lJson.Parse(lJsonString);
             error := lJson.Values['message'].AsString;
             FreeAndNil(lJson);
             ShowMessage( UpperCase(IntToStr(RestClient1.ResponseCode) + ' - ' + error));
           end;
          end;
        Screen.Cursor := crDefault;
        //m_vlcontinua  := False;
      end;
    end;

  if lJson.IsJsonObject(lJsonString) then
  begin
      lJson := TJson.Create;
      lJson.Parse(lJsonString);

      _jsonobj01   := lJson.JsonObject;

      if _jsonobj01.Values['error'].AsString <> '' then
      begin
        Memo1.Lines.Add('Error message: '+_jsonobj01.Values['message'].AsString);
        //Edit4.text := _jsonobj01.Values['message'].AsString;


      end
      else
      begin
        ListBox1.Items.Clear;
        _jsonarray01 := _jsonobj01.Values['response'].AsObject.Values['item'].AsArray;
        //if _jsonarray01.IsJsonArray(_jsonarray01) then
        //begin
        item_id_list := _jsonarray01[0].AsObject.Values['item_id'].AsString;
          for i := 1 to _jsonarray01.Count-1 do
          begin
            item_id_list := Format('%s,%s',[item_id_list,_jsonarray01[i].AsObject.Values['item_id'].AsString]);
          //ListBox1.Items.Add(_jsonarray01[i].AsObject.Values['item_id'].AsString);
          end;
          ListBox1.Items.Add(item_id_list);

          path02 := '/api/v2/product/get_item_base_info';
          timest02 := IntToStr(DateTimeToUnix(Now)+10800);
          base_string02 := Format('%s%s%s%s%s',[partner_id,path02,timest02,access_token,shop_id]);
          sign02 := CalculateHMACSHA256(base_string02,partner_key);
          m_resource02 := Format('%s%s?partner_id=%s&timestamp=%s&access_token=%s&shop_id=%s&sign=%s&item_id_list=%s',[host,path02,partner_id,timest02,access_token,shop_id,sign02,item_id_list]);


          try
            lJsonString02 := RestClient1
                            .Resource( m_resource02 )
                            .Header('Content-Type', 'application/json')
                            .Get;

            except
            on E: Exception do
            begin
              if E is EHTTPError then
                if EHTTPError(E).ErrorCode = RestClient1.ResponseCode then
                begin
                  if lJson.IsJsonObject(lJsonString) then
                  begin
                    lJson := TJson.Create;
                    lJson.Parse(lJsonString);
                    error := lJson.Values['message'].AsString;
                    FreeAndNil(lJson);
                    ShowMessage( UpperCase(IntToStr(RestClient1.ResponseCode) + ' - ' + error));
                  end;
                end;
                Screen.Cursor := crDefault;
                //m_vlcontinua  := False;
            end;
          end;

            if lJson.IsJsonObject(lJsonString02) then
            begin
              lJson := TJson.Create;
              lJson.Parse(lJsonString02);

              _jsonobj02   := lJson.JsonObject;

              if _jsonobj02.Values['error'].AsString <> '' then
              begin
                Memo1.Lines.Add('Error message: '+_jsonobj02.Values['message'].AsString);
              end
              else
              begin
                _jsonarray02 := _jsonobj02.Values['response'].AsObject.Values['item_list'].AsArray;
                descricao := '';
                for i := 0 to _jsonarray02.Count-1 do
                begin
                  descricao := Format('%s - %s - %s ',[_jsonarray02[i].AsObject.Values['item_id'].AsString,
                                                       _jsonarray02[i].AsObject.Values['item_name'].AsString,
                                                       _jsonarray02[i].AsObject.Values['item_sku'].AsString]);
                  ListBox1.Items.Add(descricao);


                end;
              end;


            end;





        //end;

      end;
  end;


  Memo1.Lines.Add('Timestamp: '+timest);
  Memo1.Lines.Add('Sign: '+sign);
  Memo1.Lines.Add(Format('Link de de consulta: %s',[m_resource]));
  Memo1.Lines.Add(Format('Num de Itens Encontrados: %s', [_jsonobj01.Values['response'].AsObject.Values['total_count'].AsString]));
  Memo1.Lines.Add(Format('Link de de consulta dos produtos: %s',[m_resource02]));


  Screen.Cursor := crDefault;

end;

procedure TForm1.Button6Click(Sender: TObject);
var
 host, path, redirect_url, timest, res, partner_id, partner_key,
 sign, url, base_string, lJsonString, m_resource, error, shop_id,
 access_token, item_name : string;
 auth_code, body : string;
 lJson: TJson;
 _jsonarray01: TJSONArray;
 _jsonobj01: TJSONObject;
 i : integer;
 myFile : TextFile;


begin
  Screen.Cursor := crHourGlass;
  Memo1.Lines.Clear();

  AssignFile(myFile, 'infos.txt');

  Reset(myFile);

  Read(myFile, lJsonString);
  //Memo1.Lines.Add(lJsonString);


  if lJson.IsJsonObject(lJsonString) then
  begin
    lJson := TJson.Create;
    lJson.Parse(lJsonString);

    _jsonobj01   := lJson.JsonObject;

    access_token := _jsonobj01.Values['access_token'].AsString;

  end;
  CloseFile(myFile);


  host := 'https://partner.test-stable.shopeemobile.com';
  path := '/api/v2/product/search_item';
  //redirect_url := 'http://www.polinfoinformatica.com.br';
  partner_id := '1077689';
  shop_id := '96276';
  timest := IntToStr(DateTimeToUnix(Now)+10800);
  partner_key := '7569704d6e5a616e665848427351786c79537769506e674c4241416a59576d72';
  base_string := Format('%s%s%s%s%s',[partner_id,path,timest,access_token,shop_id]);
  sign := CalculateHMACSHA256(base_string,partner_key);
  item_name := Edit8.Text;
  m_resource := Format('%s%s?partner_id=%s&timestamp=%s&access_token=%s&shop_id=%s&sign=%s&page_size=100&offset=0&item_name=%s',[host,path,partner_id,timest,access_token,shop_id,sign,item_name]);







  {try
        lJsonString := RestClient1
                 .Resource( m_resource )
                 .Header('Content-Type', 'application/json')
                 .Get;
    except
      on E: Exception do
      begin
        if E is EHTTPError then
          if EHTTPError(E).ErrorCode = RestClient1.ResponseCode then
          begin
           if lJson.IsJsonObject(lJsonString) then
           begin
             lJson := TJson.Create;
             lJson.Parse(lJsonString);
             error := lJson.Values['message'].AsString;
             FreeAndNil(lJson);
             ShowMessage( UpperCase(IntToStr(RestClient1.ResponseCode) + ' - ' + error));
           end;
          end;
        Screen.Cursor := crDefault;
        //m_vlcontinua  := False;
      end;
    end;

  if lJson.IsJsonObject(lJsonString) then
  begin
      lJson := TJson.Create;
      lJson.Parse(lJsonString);

      _jsonobj01   := lJson.JsonObject;

      if _jsonobj01.Values['error'].AsString <> '' then
      begin
        Memo1.Lines.Add('Error message: '+_jsonobj01.Values['message'].AsString);
        //Edit4.text := _jsonobj01.Values['message'].AsString;


      end
      else
      begin
        ListBox1.Items.Clear;
        _jsonarray01 := _jsonobj01.Values['response'].AsObject.Values['item'].AsArray;
        //if _jsonarray01.IsJsonArray(_jsonarray01) then
        //begin
          for i := 0 to _jsonarray01.Count-1 do
          begin
            ListBox1.Items.Add(_jsonarray01[i].AsObject.Values['item_id'].AsString);

          end;


        //end;

      end;
  end;    }


  Memo1.Lines.Add('Timestamp: '+timest);
  Memo1.Lines.Add('Sign: '+sign);
  Memo1.Lines.Add(Format('Link de de consulta: %s',[m_resource]));
  //Memo1.Lines.Add(Format('Num de Itens Encontrados: %s', [_jsonobj01.Values['response'].AsObject.Values['total_count'].AsString]));


  Screen.Cursor := crDefault;

end;

procedure TForm1.Button7Click(Sender: TObject);
var
 host, path, redirect_url, timest, res, partner_id, partner_key,
 sign, url, base_string, lJsonString, m_resource, error, shop_id,
 access_token, time_from, time_to, order_status, time_range_field,
 order_sn_list : string;
 auth_code, body : string;
 lJson: TJson;
 _jsonarray01: TJSONArray;
 _jsonobj01: TJSONObject;
 i : integer;
 myFile : TextFile;
begin
  Screen.Cursor := crHourGlass;
  Memo1.Lines.Clear();

  AssignFile(myFile, 'infos.txt');

  Reset(myFile);

  Read(myFile, lJsonString);
  //Memo1.Lines.Add(lJsonString);


  if lJson.IsJsonObject(lJsonString) then
  begin
    lJson := TJson.Create;
    lJson.Parse(lJsonString);

    _jsonobj01   := lJson.JsonObject;

    access_token := _jsonobj01.Values['access_token'].AsString;

  end;
  CloseFile(myFile);


  host := 'https://partner.test-stable.shopeemobile.com';
  path := '/api/v2/order/get_order_list';
  //redirect_url := 'http://www.polinfoinformatica.com.br';
  partner_id := '1077689';
  shop_id := '96276';
  timest := IntToStr(DateTimeToUnix(Now)+10800);
  partner_key := '7569704d6e5a616e665848427351786c79537769506e674c4241416a59576d72';
  base_string := Format('%s%s%s%s%s',[partner_id,path,timest,access_token,shop_id]);
  sign := CalculateHMACSHA256(base_string,partner_key);
  time_from := IntToStr(DateTimeToUnix(DateTimePicker1.Date - TimeOf(DateTimePicker1.Date)));
  time_to := IntToStr(DateTimeToUnix(DateTimePicker2.Date - TimeOf(DateTimePicker2.Date))+86399);
  order_status := ComboBox1.Text;
  time_range_field := ComboBox2.Text;
  m_resource := Format('%s%s?partner_id=%s&timestamp=%s&access_token=%s&shop_id=%s&sign=%s&page_size=100&time_range_field=%s&time_from=%s&time_to=%s&order_status=%s',
                                                                        [host,path,partner_id,timest,access_token,shop_id,sign,time_range_field,time_from,time_to,order_status]);

  ListBox2.Items.Clear;
  ListBox2.Items.Add(IntToStr(DateTimeToUnix(DateTimePicker1.Date - TimeOf(DateTimePicker1.Date))));
  ListBox2.Items.Add(IntToStr(DateTimeToUnix(DateTimePicker2.Date - TimeOf(DateTimePicker2.Date))+86399));
  ListBox2.Items.Add(ComboBox1.Text);


  try
    lJsonString := RestClient1
                 .Resource( m_resource )
                 .Header('Content-Type', 'application/json')
                 .Get;
    except
      on E: Exception do
      begin
        if E is EHTTPError then
          if EHTTPError(E).ErrorCode = RestClient1.ResponseCode then
          begin
           if lJson.IsJsonObject(lJsonString) then
           begin
             lJson := TJson.Create;
             lJson.Parse(lJsonString);
             error := lJson.Values['message'].AsString;
             FreeAndNil(lJson);
             ShowMessage( UpperCase(IntToStr(RestClient1.ResponseCode) + ' - ' + error));
           end;
          end;
        Screen.Cursor := crDefault;
        //m_vlcontinua  := False;
      end;
    end;

  if lJson.IsJsonObject(lJsonString) then
  begin
      lJson := TJson.Create;
      lJson.Parse(lJsonString);

      _jsonobj01   := lJson.JsonObject;

      if _jsonobj01.Values['error'].AsString <> '' then
      begin
        Memo1.Lines.Add('Error message: '+_jsonobj01.Values['message'].AsString);
        //Edit4.text := _jsonobj01.Values['message'].AsString;


      end
      else
      begin
//        ListBox2.Items.Clear;
        _jsonarray01 := _jsonobj01.Values['response'].AsObject.Values['order_list'].AsArray;
        //if _jsonarray01.IsJsonArray(_jsonarray01) then
        //begin
        order_sn_list := _jsonarray01[0].AsObject.Values['order_sn'].AsString;
        for i := 1 to _jsonarray01.Count-1 do
        begin
          order_sn_list := Format('%s,%s',[order_sn_list,_jsonarray01[i].AsObject.Values['order_sn'].AsString]);
        //ListBox1.Items.Add(_jsonarray01[i].AsObject.Values['item_id'].AsString);
        end;
        ListBox2.Items.Add(order_sn_list);

      end;
  end;














  Memo1.Lines.Add('Timestamp: '+timest);
  Memo1.Lines.Add('Sign: '+sign);
  Memo1.Lines.Add(Format('Link de de consulta: %s',[m_resource]));
  //Memo1.Lines.Add(Format('Num de Itens Encontrados: %s', [_jsonobj01.Values['response'].AsObject.Values['total_count'].AsString]));


  Screen.Cursor := crDefault;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
 i,h : integer;
begin
if ListBox2.ItemIndex > -1 then // always check if something is selected
  Form2.Edit1.Text := ListBox2.Items[ListBox2.ItemIndex];

  Form2.Show();
end;

procedure TForm1.Button9Click(Sender: TObject);
var
 i,h : integer;
 codigo_produto : string;
begin
if ListBox1.ItemIndex > -1 then // always check if something is selected
  codigo_produto := ListBox1.Items[ListBox1.ItemIndex];

  Form3.Edit1.Text := Copy(codigo_produto,0,Pos('-',codigo_produto)-2);
  Form3.Show();
end;




end.
