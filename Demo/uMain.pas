unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, zBase, zObjInspector, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, Vcl.Styles, Vcl.Themes, Vcl.Grids, Vcl.ValEdit,
  Vcl.Menus, Generics.Collections, System.Rtti;

type
  TParam = class
  private
    FValue: String;
    FName: String;
    procedure SetValue(const Value: String);
    procedure SetName(const Value: String);
  public
    property Name: String read FName write SetName;
  published
    property Value: String read FValue write SetValue;
  end;

  TParamGroup = class
  private
    Fname: String;
    Factive: Boolean;
    Fparams: TList<TParam>;
    Fparam: TParam;
    Fparam2: TParam;
    FVariable: TValue;
    Fvarianten: Variant;
    procedure Setactive(const Value: Boolean);
    procedure Setname(const Value: String);
    procedure Setparams(const Value: TList<TParam>);
    procedure Setparam(const Value: TParam);
    procedure Setparam2(const Value: TParam);
    procedure SetVariable(const Value: TValue);
    procedure Setvarianten(const Value: Variant);
   published
      property Variable: TValue read FVariable write SetVariable;
      property Name : String read Fname write Setname;
      property param: TParam read Fparam write Setparam;
      property param2: TParam read Fparam2 write Setparam2;
      property Active: Boolean read Factive write Setactive;
      property params : TList<TParam> read Fparams write Setparams;
      property varianten : Variant read Fvarianten;
   end;

   TParamGroup2 = class(TParamGroup)
   private
      fAnother : String;

   published
      property Another : String read fAnother write fAnother;
      property Name: String read fName;

   end;
  TMain = class(TForm)
    zObjectInspector1: TzObjectInspector;
    Panel1: TPanel;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Panel3: TPanel;
    LabeledEdit1: TLabeledEdit;
    SpeedButton1: TSpeedButton;
    CheckBox1: TCheckBox;
    RadioButton1: TRadioButton;
    Label1: TLabel;
    ObjsCombo: TComboBox;
    CheckBox2: TCheckBox;
    Label2: TLabel;
    StylesCombo: TComboBox;
    BtnMultiComponents: TButton;
    Memo1: TMemo;
    ListBox1: TListBox;
    SpeedButton2: TSpeedButton;
    Image1: TImage;
    BalloonHint1: TBalloonHint;
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    PopupItemTest1: TMenuItem;
    OptSortByCategory: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ObjsComboChange(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    function zObjectInspector1BeforeAddItem(Sender: TControl;
      PItem: PPropItem): Boolean;
    procedure StylesComboChange(Sender: TObject);
    procedure BtnMultiComponentsClick(Sender: TObject);
    procedure OptSortByCategoryClick(Sender: TObject);
    function zObjectInspector1GetItemReadOnly(Sender: TControl; PItem: PPropItem): Boolean;
    function zObjectInspector1GetItemFriendlyName(Sender: TControl; PItem: PPropItem): string;
  private
    FIncludeEvent: Boolean;
    procedure GetObjsList;
    procedure EnumStyles;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

uses TypInfo;
{$R *.dfm}

procedure TMain.BtnMultiComponentsClick(Sender: TObject);
var
  Host: TzObjectHost;
  i: Integer;
begin
  Host := TzObjectHost.Create;
  with GroupBox1 do
    for i := 0 to ControlCount - 1 do
      Host.AddObject(Controls[i], Controls[i].Name);

  zObjectInspector1.Component := Host;
end;

procedure TMain.CheckBox2Click(Sender: TObject);
begin
  FIncludeEvent := TCheckBox(Sender).Checked;
  zObjectInspector1.UpdateProperties(True);
end;

procedure TMain.ObjsComboChange(Sender: TObject);
var
  Com: TComponent;
begin
  Com := nil;
  with TComboBox(Sender) do
  begin
    if ItemIndex > -1 then
      Com := TComponent(Items.Objects[ItemIndex]);
  end;
  if Assigned(Com) then
    zObjectInspector1.Component := Com;
end;

procedure TMain.OptSortByCategoryClick(Sender: TObject);
var
   paramGroup : TParamGroup2;
begin

   paramGroup :=  TParamGroup2.Create;
   // paramGroup.name := 'a test';
   paramGroup.param := TParam.Create;
   paramGroup.param.Name := 'test_param_1';
   paramGroup.param.Value := 'a test value';

   paramGroup.param2 := TParam.Create;
   paramGroup.param2.Name := 'test param 2';
   paramGroup.param2.Value := 'a test value 2';


   paramGroup.params := TList<TParam>.Create;
   paramGroup.params.Add(TParam.Create);
   paramGroup.params[0].Name := 'first name';
   paramGroup.params[0].Value := 'first';
   paramGroup.params.Add(paramGroup.param);
   paramGroup.params.Add(paramGroup.param2);

   paramGroup.Another := 'another world';


   paramGroup.Variable := 12;

   zObjectInspector1.ObjectVisibility :=  mvPublished;
   zObjectInspector1.Component := paramGroup;
//   zObjectInspector1.ReadOnlyColor

   zObjectInspector1.RegisterPropertyInCategory('group2', 'Active');
   zObjectInspector1.RegisterPropertyInCategory('group1', 'param');
   zObjectInspector1.RegisterPropertyInCategory('group1', 'Name');
   zObjectInspector1.SortByCategory := false;
end;

procedure TMain.StylesComboChange(Sender: TObject);
begin
  with TComboBox(Sender) do
  begin
    if ItemIndex > -1 then
      TStyleManager.SetStyle(Items[ItemIndex]);
  end;
end;

procedure TMain.EnumStyles;
var
  s: string;
begin
  StylesCombo.Clear;
  for s in TStyleManager.StyleNames do
    StylesCombo.Items.Add(s);
end;

procedure TMain.GetObjsList;
var
  i: Integer;
begin
  ObjsCombo.Clear;
  ObjsCombo.Text := '';
  with GroupBox1 do
    for i := 0 to ControlCount - 1 do
      ObjsCombo.Items.AddObject(Controls[i].Name, Controls[i]);
ObjsCombo.Items.AddObject(PopupItemTest1.Name,PopupItemTest1);
  with ObjsCombo do
  begin
    ItemIndex := 0;
    zObjectInspector1.Component := Items.Objects[ItemIndex];
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  GetObjsList;
  EnumStyles;
end;

function TMain.zObjectInspector1BeforeAddItem(Sender: TControl;
  PItem: PPropItem): Boolean;
begin
  Result := True;
  if not FIncludeEvent then
    Result := PItem.Prop.PropertyType.TypeKind <> tkMethod;
end;

function TMain.zObjectInspector1GetItemFriendlyName(Sender: TControl; PItem: PPropItem): string;
var
   str : String;
begin
   str := PItem.QualifiedName;
   Result:= str.Substring(str.LastIndexOf('.')+1);
end;

function TMain.zObjectInspector1GetItemReadOnly(Sender: TControl; PItem: PPropItem): Boolean;
begin
   result := PItem.Name = 'Name';
end;

{ TParamGroup }

procedure TParamGroup.Setactive(const Value: Boolean);
begin
  Factive := Value;
end;

procedure TParamGroup.Setname(const Value: String);
begin
  Fname := Value;
end;

procedure TParamGroup.Setparam(const Value: TParam);
begin
  Fparam := Value;
end;

procedure TParamGroup.Setparam2(const Value: TParam);
begin
  Fparam2 := Value;
end;

procedure TParamGroup.Setparams(const Value: TList<TParam>);
begin
  Fparams := Value;
end;

procedure TParamGroup.SetVariable(const Value: TValue);
begin
  FVariable := Value;
end;

procedure TParamGroup.Setvarianten(const Value: Variant);
begin
  Fvarianten := Value;
end;

{ TParam }



{ TParam }

procedure TParam.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TParam.SetValue(const Value: String);
begin
  FValue := Value;
end;

end.
