VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "ieframe.dll"
Begin VB.Form Form1 
   Caption         =   "routing-machine"
   ClientHeight    =   9795
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   14475
   LinkTopic       =   "Form1"
   ScaleHeight     =   9795
   ScaleWidth      =   14475
   StartUpPosition =   2  'CenterScreen
   Begin VB.ComboBox Combo1 
      Height          =   315
      ItemData        =   "routing-machine.frx":0000
      Left            =   1800
      List            =   "routing-machine.frx":000A
      TabIndex        =   7
      Text            =   "carfast"
      Top             =   240
      Width           =   1215
   End
   Begin VB.TextBox Text1 
      Height          =   1335
      Left            =   3240
      MousePointer    =   1  'Arrow
      MultiLine       =   -1  'True
      TabIndex        =   6
      Text            =   "routing-machine.frx":0022
      Top             =   240
      Width           =   4095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Route"
      Enabled         =   0   'False
      Height          =   1335
      Left            =   240
      TabIndex        =   1
      Top             =   240
      Width           =   1335
   End
   Begin SHDocVwCtl.WebBrowser WebBrowser1 
      Height          =   2535
      Left            =   120
      TabIndex        =   0
      Top             =   1800
      Width           =   7335
      ExtentX         =   12938
      ExtentY         =   4471
      ViewMode        =   0
      Offline         =   0
      Silent          =   0
      RegisterAsBrowser=   0
      RegisterAsDropTarget=   1
      AutoArrange     =   0   'False
      NoClientEdge    =   0   'False
      AlignLeft       =   0   'False
      NoWebView       =   0   'False
      HideFileNames   =   0   'False
      SingleClick     =   0   'False
      SingleSelection =   0   'False
      NoFolders       =   0   'False
      Transparent     =   0   'False
      ViewID          =   "{0057D0E0-3573-11CF-AE69-08002B2E1262}"
      Location        =   ""
   End
   Begin VB.Label Label4 
      Caption         =   "- min"
      Height          =   495
      Left            =   9120
      TabIndex        =   5
      Top             =   1080
      Width           =   2055
   End
   Begin VB.Label Label3 
      Caption         =   "Total Time"
      Height          =   495
      Left            =   7680
      TabIndex        =   4
      Top             =   1080
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "- km"
      Height          =   495
      Left            =   9120
      TabIndex        =   3
      Top             =   360
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "TotalDistance"
      Height          =   495
      Left            =   7680
      TabIndex        =   2
      Top             =   360
      Width           =   1215
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
    ' You need an xServer-internet token to run this sample.
    xtok = ""
    If (xtok = "") Then
        MsgBox "You need an xServer-internet token to run this sample!"
    End If
    
WebBrowser1.Navigate (App.Path + "/routing-machine/index.html?xtok=" + xtok)
End Sub

Private Sub Form_Resize()
   WebBrowser1.Width = Width - WebBrowser1.Left - 400
   WebBrowser1.Height = Height - 2600
End Sub

' document has to be loaded first!
Private Sub WebBrowser1_DocumentComplete(ByVal pDisp As Object, URL As Variant)
    Command1.Enabled = True
End Sub

' set routing params and calculate the route
Private Sub Command1_Click()
    InvokeJs "setPlan('" + Replace(Text1.Text, vbCrLf, vbNullString) + "')"
    InvokeJs "setProfile('" + Combo1.Text + "')"
    InvokeJs "route()"
End Sub
    
' display result summary
Private Sub OnRoutesFound(strResult As String)
    vals = Split(strResult, "|")
    Label2.Caption = CStr(vals(0) / 1000) + " km"
    Label4.Caption = CStr(Round(vals(1) / 60)) + " min"
End Sub

' event-handling
Private Sub WebBrowser1_StatusTextChange(ByVal method As String)
    If method = "onRoutesFound" Then
        OnRoutesFound (WebBrowser1.Document.Body.GetAttribute("ExtData"))
    End If
End Sub

' js invocation
Private Function InvokeJs(js As String)
    jsWrap = "document.body.setAttribute('ExtData', " + js + ");"
    WebBrowser1.Document.parentWindow.execScript jsWrap
    InvokeJs = WebBrowser1.Document.Body.GetAttribute("ExtData")
End Function
