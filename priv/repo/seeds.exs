# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Todo.Repo.insert!(%Todo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Todo.Repo.insert!(%Todo.List.Task{
    name: "Book Reading",
    status: 0
})

Todo.Repo.insert!(%Todo.List.Task{
    name: "Story Reading",
    status: 1
})

Todo.Repo.insert!(%Todo.List.Task{
    name: "DIY",
    status: 2
})
