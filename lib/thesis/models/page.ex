defmodule Thesis.Page do
  @moduledoc """
  Represents a page (dynamic or static), and also contains meta data like
  title, description, and redirect if necessary.
  """
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, fetch_field: 2, put_change: 3]

  @type t :: %Thesis.Page{
    id: any,
    slug: String.t,
    title: String.t | nil,
    template: String.t | nil,
    redirect_url: String.t | nil,
    description: String.t | nil,
    inserted_at: any,
    updated_at: any
  }

  schema "thesis_pages" do
    field :slug, :string
    field :title, :string
    field :template, :string
    field :redirect_url, :string
    field :description, :string

    timestamps
  end

  @valid_attributes [:slug, :title, :description, :redirect_url, :template]
  @required_attributes [:slug]

  @doc """
  Returns whether the page redirects to another page.

  Examples:

      iex> Thesis.Page.redirected?(%Thesis.Page{slug: "", redirect_url: nil})
      false
      iex> Thesis.Page.redirected?(%Thesis.Page{slug: "", redirect_url: ""})
      false
      iex> Thesis.Page.redirected?(%Thesis.Page{slug: "", redirect_url: "/asdf"})
      true
  """
  def redirected?(nil), do: false
  def redirected?(%Thesis.Page{redirect_url: url}) when url in [nil, ""], do: false
  def redirected?(_), do: true

  @doc """
  Changeset for PageContent structs.
  """
  def changeset(page, params \\ %{}) do
    page
    |> cast(params, @valid_attributes)
    |> validate_required(@required_attributes)
    |> slugify
  end

  defp slugify(changeset) do
    if {:data, slug} = fetch_field(changeset, :slug) do
      put_change(changeset, :slug, sanitize_slug(slug))
    else
      changeset
    end
  end

  def sanitize_slug(slug) do
    slug
    |> String.downcase
    |> String.replace(" ", "-")
  end

end
