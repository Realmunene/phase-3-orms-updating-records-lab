require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id= nil,name,grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade) VALUES(?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    end
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    self
  end

  def self.create(name, grade)
    Student.new(name, grade).save
    
  end

  def self.new_from_db(row)
    self.new(id=row[0], name=row[1], grade=row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    results = DB[:conn].execute(sql, name)
    results.map{|result| self.new_from_db(result)}.first

  end

  def update 
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
