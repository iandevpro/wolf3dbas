$Debug
' hex2bin.bas - Converts hex dump format to binary
' Input format example:
' 0080:  00 1c 00 00 19 00 00 16   00 00 13 00 00 10 00 00

Dim inputFile As String
Dim outputFile As String
Dim lineText As String
Dim hexBytes As String
Dim byteValue As _Byte
Dim i As Integer
Dim j As Integer
Dim temp As String

' Get input and output filenames
Input "Enter input filename: ", inputFile
Input "Enter output filename: ", outputFile

' Open files
Open inputFile For Input As #1
Open outputFile For Binary As #2

' Process each line
Do While Not EOF(1)
    Line Input #1, lineText
    
    ' Skip empty lines
    If Len(lineText) = 0 Then GoTo NextLine
    
    ' Find the colon to locate start of hex data
    i = InStr(lineText, ":")
    If i = 0 Then GoTo NextLine
    
    ' Extract hex data part
    hexBytes = Mid$(lineText, i + 1)
    
    ' Process each byte
    i = 1
    Do While i <= Len(hexBytes)
        ' Skip spaces
        Do While i <= Len(hexBytes) And Mid$(hexBytes, i, 1) = " "
            i = i + 1
        Loop
        
        ' Get next two characters as hex
        If i + 1 <= Len(hexBytes) Then
            temp = Mid$(hexBytes, i, 2)
            ' Convert hex to byte
            byteValue = Val("&H" + temp)
            ' Write byte to output file
            Put #2, , byteValue
            i = i + 2
        End If
    Loop
    
NextLine:
Loop

' Close files
Close #1
Close #2

Print "Conversion complete!"
End 