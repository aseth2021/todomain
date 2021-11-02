defmodule Todo.ListTest do
  use Todo.DataCase

  alias Todo.List

  describe "tasks" do
    alias Todo.List.Task

    @valid_attrs %{name: "some name", status: 42}
    @update_attrs %{name: "some updated name", status: 43}
    @invalid_attrs %{name: nil, status: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> List.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert List.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert List.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = List.create_task(@valid_attrs)
      assert task.name == "some name"
      assert task.status == 42
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = List.update_task(task, @update_attrs)
      assert task.name == "some updated name"
      assert task.status == 43
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = List.update_task(task, @invalid_attrs)
      assert task == List.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = List.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> List.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = List.change_task(task)
    end
  end
end
