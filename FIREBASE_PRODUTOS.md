# Estrutura de Produtos no Firebase Firestore

Para que o app exiba corretamente os produtos com **tamanhos, preços e estoque** (`stock`), configure os documentos na coleção `products` conforme abaixo.

## Coleção: `products`

Cada documento representa um produto e deve ter os seguintes campos:

| Campo        | Tipo   | Obrigatório | Descrição                                      |
|-------------|--------|-------------|------------------------------------------------|
| `name`      | string | Sim         | Nome do produto                                |
| `description` | string | Não       | Descrição do produto                           |
| `images`    | array  | Não         | Lista de URLs de imagens (Firebase Storage)    |
| `basePrice` ou `price` | number | Não | Preço base (fallback quando não há tamanhos)   |
| `sizes`     | array  | Sim*        | Lista de variações por tamanho (ver abaixo)   |

\* Se o produto tiver tamanhos diferentes (P, M, GG), use o array `sizes`.

---

## Estrutura do array `sizes`

Cada elemento do array é um objeto com **name**, **price** e **stock**:

```
sizes [
  0: { name: "P",   price: 19.99, stock: 10 }
  1: { name: "M",   price: 21.99, stock: 5  }
  2: { name: "GG",  price: 23.99, stock: 2  }
]
```

| Campo  | Tipo   | Descrição                              |
|--------|--------|----------------------------------------|
| `name` | string | Nome do tamanho (P, M, G, GG, etc.)    |
| `price`| number | Preço deste tamanho                    |
| `stock`| number | **Quantidade em estoque** do tamanho   |

---

## Exemplo no Firebase Console

1. Acesse **Firebase Console** → seu projeto → **Firestore Database**
2. Crie ou edite um documento na coleção `products`
3. Adicione o campo `sizes` como **array**
4. Em cada posição (0, 1, 2...), adicione um **map** com:
   - `name` (string): ex. `"P"`
   - `price` (number): ex. `19.99`
   - `stock` (number): ex. `10` — quantidade disponível

O app lê esses dados e exibe a quantidade de cada tamanho na tela do produto (ex.: "10 disp." ao lado de cada opção).

---

## Chaves alternativas aceitas pelo app

O código aceita variações de nome de campo:

- **name** ou **nome**
- **price** ou **preco**
- **stock** ou **estoque**

Isso permite flexibilidade se os dados foram cadastrados com nomes em português.
