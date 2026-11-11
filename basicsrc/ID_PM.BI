' ID_PM.H - Page Manager header
' The original paged VSWAP chunks between conventional, EMS and XMS memory.
' Here the whole page file (1.5 MB for WL6) is loaded into one _MEM block (PMData)
' and PM_GetPage returns the byte offset of a page inside it.
$If INCLUDE_ID_PM_BI = UNDEFINED Then
    $Let INCLUDE_ID_PM_BI = 1

    Const PMPageSize = 4096

    Dim Shared ChunksInFile As Long ' word
    Dim Shared PMSpriteStart As Long ' word
    Dim Shared PMSoundStart As Long ' word

    ' PageListStruct: only offset and length are needed without paging (dynamic, sized by PML_OpenPageFile)
    ReDim Shared PMPageOffset(0) As Long ' offset of chunk into file, 0 = sparse page
    ReDim Shared PMPageLength(0) As Long ' length of the chunk

    Dim Shared PMData As _MEM ' the whole page file
    Dim Shared PMStarted As Integer

    Declare Sub PM_Startup ()
    Declare Sub PM_Shutdown ()
    Declare Function PM_GetPage& (pagenum As Integer)
    Declare Function PM_GetSpritePage& (v As Integer)
    Declare Function PM_GetSoundPage& (v As Integer)

$End If
