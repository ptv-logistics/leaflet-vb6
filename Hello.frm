VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "ieframe.dll"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   4230
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   8130
   LinkTopic       =   "Form1"
   ScaleHeight     =   4230
   ScaleWidth      =   8130
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Say Hello to Browser"
      Enabled         =   0   'False
      Height          =   495
      Left            =   360
      TabIndex        =   1
      Top             =   360
      Width           =   1935
   End
   Begin SHDocVwCtl.WebBrowser WebBrowser1 
      Height          =   2535
      Left            =   360
      TabIndex        =   0
      Top             =   1200
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
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
    WebBrowser1.Navigate (App.Path + "/hello.html")
End Sub

' document has to be loaded!
Private Sub WebBrowser1_DocumentComplete(ByVal pDisp As Object, URL As Variant)
    Command1.Enabled = True
End Sub

Private Sub Command1_Click()
    result = InvokeJs("Say('Hello Browser')")
    MsgBox result
End Sub

' event-handling - use status text
Private Sub WebBrowser1_StatusTextChange(ByVal method As String)
    If method = "Say" Then ' the method is the status text
        ' the argument is in ExtData
        msg = WebBrowser1.Document.Body.GetAttribute("ExtData")
        
        MsgBox msg
        
        ' write result to ExtData
        WebBrowser1.Document.Body.SetAttribute "ExtData", "Said """ + msg + """"
    End If
End Sub

' js invocation
Private Function InvokeJs(js As String)
    jsWrap = "document.body.setAttribute('ExtData', " + js + ");"
    WebBrowser1.Document.parentWindow.execScript jsWrap
    InvokeJs = WebBrowser1.Document.Body.GetAttribute("ExtData")
End Function

