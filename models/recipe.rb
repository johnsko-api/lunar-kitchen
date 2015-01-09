def db_connection
  begin
    connection = PG.connect(dbname:'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

class Recipe
  attr_reader :name, :id, :instructions, :description, :ingredients
  def initialize(name, id, instructions, description, ingredients)
    @name = name
    @id = id
    @description = description
    @instructions = instructions
  end

  def self.all
    recipes = nil
    db_connection do |connection|
      recipes = connection.exec('SELECT name, id, instructions, description FROM recipes')
    end
    recipes_array = []
    recipes.each do |recipe|
      recipes_array << Recipe.new(recipe["name"],recipe["id"], recipe["instructions"], recipe["description"], nil)
    end
    recipes_array
  end

  def self.find(id)
    record = nil
    find_sql = "SELECT name, id, description, instructions FROM recipes WHERE recipes.id = $1"
    db_connection do |connection|
      record = connection.exec(find_sql, [id]).first
    end
    #binding.pry
    Recipe.new(record["name"], record["id"], record["instructions"], record["description"], nil)
  end

  def ingredients
    pieces = nil
    ingredients_sql = "SELECT ingredients.name AS ingredient, recipe_id FROM ingredients WHERE ingredients.recipe_id = $1"
    db_connection do |connection|
      pieces = connection.exec(ingredients_sql, [id])
    end
      array_ofingredients = []
    pieces.each do |piece|
      array_ofingredients << Ingredient.new(piece["ingredient"])
    end
    array_ofingredients
  end
end
