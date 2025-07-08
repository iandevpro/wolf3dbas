' ID_CA.H
' simulate IFDEFs settings
$If INCLUDE_ID_CA_BI = UNDEFINED Then
    $Let INCLUDE_ID_CA_BI = 1

    ' Constants
    Const NUMMAPS = 60
    Const MAPPLANES = 2
    $Let THREEBYTEGRSTARTS = 1
    $If THREEBYTEGRSTARTS = DEFINED Then
        Const FILEPOSSIZE = 3   ' Size of file position entries
    $Else
        ' THREEBYTEGRSTARTS is defined in the original C sources
        ' can comment out the following section
        'Const FILEPOSSIZE = 4   ' Size of file position entries
    $EndIf

    ' Huffman node type for graphics compression
    Type huffnode
        bit0 As Integer  ' 0-255 is a character, > is a pointer to a node
        bit1 As Integer  ' 0-255 is a character, > is a pointer to a node
    End Type

    ' Map header fields as separate arrays (was maptype)
    Dim Shared planestart(0 To NUMMAPS - 1, 0 To 2) As Long
    Dim Shared planelength(0 To NUMMAPS - 1, 0 To 2) As Integer
    Dim Shared mapwidth(0 To NUMMAPS - 1) As Integer
    Dim Shared mapheight(0 To NUMMAPS - 1) As Integer
    Dim Shared mapname(0 To NUMMAPS - 1) As String * 16

    ' Map file fields (was mapfiletype)
    Dim Shared RLEWtag As Integer
    Dim Shared headeroffsets(0 To 99) As Long
    ' tileinfo can be a separate dynamic array if needed
    ' Dim Shared tileinfo() As Byte

    ' Graphics related variables
    Dim Shared grhuffman(0 To 254) As huffnode  ' Huffman table for graphics
    Dim Shared grstarts As _MEM  ' Array of offsets in graphics file
    Dim Shared grhandle As Integer  ' Handle to graphics file
    Dim Shared pictable(NUMPICS - 1) As pictabletype  ' Picture table
    Dim Shared chunkcomplen As Long  ' Compressed chunk length
    Dim Shared chunkexplen As Long  ' Expanded chunk length

    ' Shared variables
    Dim Shared profilehandle As Integer
    Dim Shared mapon As Integer
    Dim Shared ca_levelbit As Integer
    Dim Shared ca_levelnum As Integer

    ' Map related variables
    Dim Shared tinf As _MEM  ' Pointer to tile info
    Dim Shared mapsegs(MAPPLANES - 1) As _Offset  ' Array of pointers to map segments
    ' mapheaderseg is no longer needed as a pointer array
    Dim Shared maphandle As Integer  ' Handle to map file

    ' File name variables
    ' Declare AND initialize them here. In the original sources they were initialized in ID_CA.C
    Dim Shared extension As String * 5
    '' gheadname[10]=GREXT"HEAD.",
    '' gfilename[10]=GREXT"GRAPH.",
    '' gdictname[10]=GREXT"DICT.",
    Const mheadname="MAPHEAD."
    Const mfilename="MAPTEMP."
    Const aheadname="AUDIOHED."
    Const afilename="AUDIOT."
    Const gheadname="VGAHEAD."
    Const gfilename="VGAGRAPH."
    Const gdictname="VGADICT."

$End If
