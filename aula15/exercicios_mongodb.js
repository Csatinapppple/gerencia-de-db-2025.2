//Christian Aguiar Plentz e Gerson Guilherme
//1. Crie uma coleção chamada clientes e insira um documento com nome, idade e cidade.
db.clientes.insertOne(
  {
    nome: "João Silva",
    idade: 30,
    cidade: "São Paulo"
  }
)
// 2. Insira cinco clientes diferentes na coleção clientes.
db.clientes.insertMany([
    {nome: "Maria Souza", idade: 25, cidade: "Rio de Janeiro"},
    {nome: "Carlos Pereira", idade: 35, cidade: "São Paulo"},
    {nome: "Ana Santos", idade: 22, cidade: "Porto Alegre"},
    {nome: "Pedro Costa", idade: 28, cidade: "Florianópolis"},
    {nome: "Amanda Lima", idade: 32, cidade: "São Paulo"}
])

// 3. Liste todos os documentos da coleção clientes.
db.clientes.find()

// 4. Mostre apenas o nome e a cidade de todos os clientes.
db.clientes.find({}, {nome: 1, cidade: 1, _id: 0})

// 5. Busque o cliente cujo nome seja “João Silva”.
db.clientes.find({nome: "João Silva"})

// 6. Mostre todos os clientes com idade maior que 25 anos.
db.clientes.find({idade: {$gt: 25}})

// 7. Mostre apenas os clientes que moram na cidade “São Paulo”.
db.clientes.find({cidade: {$eq: "São Paulo"}})

// 8. Apague um cliente com o nome “Maria Souza”.
db.clientes.deleteOne({nome: "Maria Souza"})

// 9. Atualize a idade do cliente “João Silva” para 35 anos.
db.clientes.updateOne(
  {nome: "João Silva"},
  {$set: {idade: 35}}
)

// 10. Adicione um novo campo chamado ativo: true em todos os documentos de clientes.
db.clientes.updateMany(
    {},
    {$set: {ativo: true}}
)

// 11. Liste todos os clientes com idade entre 20 e 30 anos.
db.clientes.find({idade: {$gte: 20, $lte: 30}})

// 12. Mostre os clientes cuja cidade seja “Porto Alegre” ou “Florianópolis”.
db.clientes.find({cidade: {$in: [ "Porto Alegre", "Florianópolis"]}})

//13. Mostre apenas os clientes com idade menor ou igual a 25 anos.
db.clientes.find({idade: {$lte: 25}})

// 14. Mostre os clientes cujo nome começa com a letra “A”.
db.clientes.find({nome: /^[aA]/})

// 15. Mostre os clientes que não moram em “São Paulo”.
db.clientes.find({cidade: { $ne: "São Paulo"}})

// 16. Liste os clientes que possuem o campo ativo igual a true.
db.clientes.find({ativo: true})

// 17. Ordene os clientes por idade em ordem crescente.
db.clientes.find().sort({idade: 1})

// 18. Ordene os clientes por nome em ordem decrescente.
db.clientes.find().sort({nome: -1})

// 19. Mostre apenas 3 clientes da coleção clientes.
db.clientes.find().limit(3)

// 20. Pule os dois primeiros clientes e mostre os próximos 3.
db.clientes.find().limit(3).skip(2)

// 21. Crie a coleção produtos e insira cinco produtos com nome, categoria, preço e estoque.
db.produtos.insertMany([
    {nome: "Notebook", categoria: "Informática", preco: 2500, estoque: 15},
    {nome: "Smartphone", categoria: "Eletrônicos", preco: 1500, estoque: 20},
    {nome: "Arroz", categoria: "Alimentos", preco: 25, estoque: 100},
    {nome: "Detergente", categoria: "Limpeza", preco: 5, estoque: 50},
    {nome: "Copo Descartável", categoria: "Descartáveis", preco: 15, estoque: 200}
])

// 22. Mostre todos os produtos com preço maior que 100.
db.produtos.find({preco: {$gt: 100}})

// 23. Liste os produtos com estoque igual a 0.
db.produtos.find({estoque: 0})

// 24. Mostre apenas o nome e preço dos produtos da categoria “Eletrônicos”.
db.produtos.find(
    {categoria: "Eletrônicos"},
    {nome: 1, preco: 1, _id: 0}
)

// 25. Atualize o preço de todos os produtos da categoria “Alimentos” em +10%.
db.produtos.updateMany(
    {categoria: "Alimentos"},
    {$mul: {preco: 1.10}}
)

// 26. Exclua todos os produtos da categoria “Descartáveis”.
db.produtos.deleteMany({categoria: "Descartáveis"})

// 27. Liste os produtos cujo preço seja maior que 50 e estoque maior que 10.
db.produtos.find({
    preco: {$gt: 50},
    estoque: {$gt: 10}
})

// 28. Liste os produtos cujo preço seja menor que 100 ou estoque menor que 5.
db.produtos.find({
    $or: [
        {preco: {$lt: 100}},
        {estoque: {$lt: 5}}
    ]
})
// 29. Mostre os produtos que não pertencem à categoria “Limpeza”.
db.produtos.find({categoria: {$ne: "Limpeza"}})

// 30. Adicione um novo campo promocao: false a todos os produtos.
db.produtos.updateMany(
    {},
    {$set: {promocao: false}}
)

// 31. Crie a coleção pedidos com os campos: cliente, itens, valorTotal e data.
db.pedidos.insertMany([
    {
        cliente: "João Silva",
        itens: ["Notebook", "Mouse", "Teclado"],
        valorTotal: 2800,
        data: new Date("2024-01-15")
    },
    {
        cliente: "Maria Souza",
        itens: ["Smartphone", "Capa"],
        valorTotal: 1550,
        data: new Date("2024-01-16")
    },
    {
        cliente: "Carlos Pereira",
        itens: ["Teclado", "Mouse", "Monitor"],
        valorTotal: 1200,
        data: new Date("2024-01-17")
    }
])

// 32. Insira três pedidos com diferentes clientes e pelo menos dois itens em cada.

// 33. Liste todos os pedidos feitos pelo cliente “João Silva”.
db.pedidos.find({cliente: "João Silva"})

// 34. Mostre os pedidos cujo valorTotal seja superior a 500.
db.pedidos.find({valorTotal: {$gt: 500}})

// 35. Busque pedidos que contenham o produto “Notebook” no campo itens.
db.pedidos.find({itens: "Notebook"})

// 36. Atualize o valor total de um pedido específico para 750.
db.pedidos.updateOne({cliente: "Jõao Silva"}, {$set: {valorTotal: 750}})

// 37. Adicione um novo item “Mouse” ao array de itens do pedido do cliente “Maria Souza”.
db.pedidos.updateOne(
    {cliente: "Maria Souza"},
    {$push: {itens: "Mouse"}}
)

// 38. Remova o item “Teclado” do pedido do cliente “Carlos Pereira”.
db.pedidos.updateOne(
    {cliente: "Carlos Pereira"},
    {$pull: {itens: "Teclado"}}
)

// 39. Liste apenas os pedidos que possuem mais de dois itens.
db.pedidos.find({
    $expr: {$gt: [{$size: "$itens"}, 2]}
})

// 40. Mostre os pedidos ordenados pelo campo data em ordem decrescente.
db.pedidos.find().sort({data: -1})

// 41. Conte quantos clientes existem na coleção clientes.
db.clientes.countDocuments()

// 42. Conte quantos produtos estão na categoria “Informática”.
db.produtos.countDocuments({categoria: "Informrática"})

// 43. Calcule o valor médio dos produtos da categoria “Alimentos”.
db.produtos.aggregate([
    {$match: {categoria: "Alimentos"}},
    {$group: {_id: null, mediaPreco: {$avg: "$preco"}}}
])

// 44. Mostre apenas os produtos com preço acima da média geral.
var res = db.produtos.aggregate([
    {$group: {_id: null, mediaGeral: {$avg: "$preco"}}},
    {$project: {_id: 0, mediaGeral: 1}}
]).toArray()

var mediaGeral = res[0]["mediaGeral"]

db.produtos.find({preco: {$gt: mediaGeral}})


// 45. Agrupe os clientes por cidade e conte quantos há em cada uma.
db.clientes.aggregate([
    {$group: {_id: "$cidade", total: {$sum: 1}}}
])

// 46. Agrupe os produtos por categoria e calcule o preço médio de cada grupo.
db.produtos.aggregate([
    {$group: {
        _id: "$categoria",
        precoMedio: {$avg: "$preco"},
        totalProdutos: {$sum: 1}
    }}
])

// 47. Crie um índice no campo nome da coleção clientes.
db.clientes.createIndex({nome: 1})
// 48. Use $regex para encontrar clientes cujo nome contenha “Silva”.
db.clientes.find({nome: {$regex: "Silva", $options: "i"}})
// 49. Mostre todos os produtos que tenham o campo promocao definido como true.
db.produtos.find({promocao: true})
// 50. Exporte a coleção clientes para um arquivo JSON usando mongoexport.
mongoexport --uri="mongodb://localhost:27017/test" --collection=clientes --out=clientes.json --jsonArray
