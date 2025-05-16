
printfn "Hello from F#"

let a = 5

let f =
    fun a -> a * 2

let x = a |> f

x |> printfn "%d"