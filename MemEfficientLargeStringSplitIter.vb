Private Iterator Function MemEfficientLargeStringSplit(str As String, delim As Char) As IEnumerable(Of String)
    If String.IsNullOrEmpty(str) Then
        Return
    End If

    Dim prevIndex As Integer = 0

    While True
        Dim currIndex As Integer = str.IndexOf(delim, prevIndex)

        If currIndex < 0 Then
            Yield str.Substring(prevIndex)
            Return
        End If

        Yield str.Substring(prevIndex, currIndex - prevIndex)

        prevIndex = currIndex + 1
    End While
End Function
