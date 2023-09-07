module Main exposing (..)

import Browser
import Html exposing (Html, h1, button, div, text, ul, li, input, p, form)
import Html.Attributes exposing (placeholder, type_, value, class, action)
import Html.Events exposing (onClick, onInput)
import Html.Extra as Html

-- Model
type alias Model =
    { todos : List Todo
    , newTodo : String
    , showCompleted : Bool
    }

type alias Todo = 
  { description : String 
  , completed : Bool
  }
init : Model
init =
    { todos = []
    , newTodo = ""
    , showCompleted = True
    }

-- Msg
type Msg
    = AddTodo
    | UpdateNewTodo String
    | ToggleCompleted
    | CompleteTask Int
    | RemoveTask Int

removeFromList i list =
  (List.take i list) ++ (List.drop (i+1) list) 

update : Msg -> Model -> Model
update msg model =
    case msg of
        AddTodo ->
            if String.trim model.newTodo /= "" then
                { model | todos = model.todos ++ [{ description = model.newTodo, completed = False }], newTodo = "" }
            else
                model

        UpdateNewTodo value ->
            { model | newTodo = value }

        ToggleCompleted ->
          { model | showCompleted = not model.showCompleted } 

        CompleteTask idx ->
          { model | todos = completeTask model.todos idx}
        RemoveTask idx ->
          { model | todos = removeFromList idx model.todos}


listItem: Int -> Todo -> Html Msg
listItem idx todo = 
  div [class "flex mb-4 items-center"] 
      [ (if not todo.completed then 
           p [class "w-full text-green-500"] [text todo.description]
       else
           p [class "w-full line-through text-slate-500"] [text todo.description]
        ),
        button [class "flex-no-shrink p-2 ml-4 mr-2 border-2 rounded hover:text-green-400 text-green-500 border-green-500 hover:bg-green-100", onClick (CompleteTask idx)] [text (completeText todo)],
        button [class "flex-no-shrink p-2 ml-2 border-2 rounded text-red-500 border-red-500 hover:text-red-400 hover:bg-red-100", onClick (RemoveTask idx)] [ text "Remove" ]
      ]

completeText: Todo -> String
completeText todo =
  if todo.completed then
    "Undone"
  else
    "Done"

viewableItems : Model -> List (Html Msg)
viewableItems model =
  List.indexedMap listItem (List.filter (\todo -> not todo.completed || model.showCompleted) model.todos)

completeTask: List Todo -> Int -> List Todo
completeTask todos idx =
  List.indexedMap  (\index todo -> 
    if idx == index then
      {todo | completed = not todo.completed }
    else
      todo
    ) todos

completedText: Model -> String
completedText state =
  if state.showCompleted then
    "Hide completed"
  else
    "Show completed"

header: Html Msg
header = h1 [class "text-3xl font-bold underline"] [ text "Elm Todo App"] 

newTodoInput: String -> Html Msg
newTodoInput newTodo =
  form [class "flex mt-4", action "#"] [
    input [ class "shadow appearance-none border rounded w-full py-2 px-3 mr-4 text-grey-700", placeholder "Add a new todo", type_ "text", onInput UpdateNewTodo, value newTodo ] [],
    button [type_ "submit", class "flex-no-shrink p-2 border-2 rounded text-teal-500 border-teal-500 hover:text-teal-400 hover:bg-teal-100", onClick AddTodo ] [ text "Add" ]
  ]

container : Model -> Html Msg
container model =
  div [class "bg-slate-100 rounded shadow p-6 m-4 w-full lg:w-3/4 lg:max-w-lg"]
      [ div [class "mb-4"]
        [
          header
          , (newTodoInput model.newTodo)
        ],
        div []
        (viewableItems model),
        button [class "flex-no-shrink p-2 ml-2 border-2 rounded text-sky-500 border-sky-500 hover:text-sky-400 hover:bg-sky-100", onClick ToggleCompleted] [ text "Toggle Completed" ]
      ]
view : Model -> Html Msg
view model =
    div [class "h-100 w-full bg-blend-lighten flex items-center justify-center bg-gradient-to-r from-cyan-500 to-blue-500 font-sans"]
        [container model]
main =
    Browser.sandbox { init = init, update = update, view = view }

