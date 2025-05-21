# 📊 My Neo4j Graph Export

Энэ репозиторт Neo4j граф өгөгдлийн санг `.cypher` формат руу экспортолсон скрипт хадгалагдсан. Уг файл нь графын бүх зангилаа (nodes), холбоосууд (relationships), болон property агуулдаг.

## 📁 Агуулга

- `all_data.cypher` – Neo4j өгөгдлийн сангийн Cypher экспортын файл

## 🛠 Ашиглах заавар

Neo4j өгөгдлийн сан дээр энэхүү `.cypher` скрипт ашиглан өгөгдлийг дахин сэргээх:

1. Neo4j Browser эсвэл Neo4j Desktop ашиглан нээх
2. `all_data.cypher` файл доторх бүх командыг хуулж буулгах
3. Гүйцэтгэх (Run/Execute)

### 📝 Жич:

- Энэхүү скрипт нь `apoc.export.cypher.all(null, {stream:true})` командаар гаргаж авсан
- `apoc` plugin суусан байх шаардлагатай

## 📦 Экспорт хийх команд (Neo4j Browser дээр)

```cypher
CALL apoc.export.cypher.all(null, {stream: true})
YIELD cypherStatements
RETURN cypherStatements;
