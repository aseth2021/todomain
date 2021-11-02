
import "../css/app.css"


import "phoenix_html"
import { Elm } from "../elm/src/Main.elm"

const elmDiv = document.getElementById("elm-main")
Elm.Main.init({ node: elmDiv })
