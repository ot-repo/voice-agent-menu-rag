-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_enrichments
(
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    client_id INT NOT NULL REFERENCES clients(id), --  1 for the enrichments common to all customers
    item VARCHAR(100) NOT NULL,
    type SMALLINT NOT NULL, -- 1: product; 2: category
    synonyms VARCHAR NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);

-- Add other indexes here
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_enrichments_client_id_type_item_deleted_at ON menu_enrichments(client_id, type, item) WHERE deleted_at IS NULL;

INSERT INTO menu_enrichments (client_id, item, "type", synonyms) VALUES
(1,'Snack dishes',2,NULL), (1,'Offers',2,NULL), (1,'Salads',2,NULL), (1,'Burger',2,NULL),
(1,'Pasta',2,NULL), (1,'Voucher for sale',2,NULL), (1,'Stuffed pizza rolls',2,NULL),
(1,'Schnitzel',2,NULL), (1,'delivery costs',2,NULL), (1,'Doner dishes',2,NULL), (1,'Casseroles',2,NULL),
(1,'Pizza',2,NULL), (1,'Indian',2,NULL), (1,'Drinks',2,'alcoholic, non-alcoholic, soft drink'),
(1,'delivery costs',1,NULL), (1,'Ketchup',1,NULL), (1,'Herbal cream',1,NULL), (1,'Mayonnaise',1,NULL),
(1,'Naan bread',1,NULL), (1,'40% discount voucher',1,NULL),
(1,'Sprite',1,'Sprite, zero-sugar carbonated soft drink, carbonated beverage, lemon-lime flavored, non-alcoholic, non alcoholic'),
(1,'Coca Cola light',1,'Coca Cola light, diet Coke, soft drink, beverage, non-alcoholic, non alcoholic'),
(1,'Salami pizza rolls',1,'menu'), (1,'Farmer''s Salad',1,'menu, diet, healthy'),
(1,'6 Chicken Nuggets ',1,'menu, chicken nuggets, chicken bites, high protein, fast food, precooked, white meat, ready-to-eat, pack of 6'),
(1,'Bolognese',1,'menu, spaghetti, red meat, non-vegetarian,pasta, tomato, onion, garlic'),
(1,'Ayran',1,'Turkish ayran, yogurt drink, dairy drink, non-alcoholic, non alcoholic'),
(1,'Fanta',1,'Fanta, carbonated soft drink, beverage, citrus-flavored, non-alcoholic, non alcoholic'),
(1,'Bottle of vodka',1,'vodka, alcohol, drink'), (1,'Bottle of whisky',1,'whisky, alcohol, drink'),
(1,'Coca Cola',1,'Coca Cola, Coke, soft drink, beverage, non-alcoholic, non alcoholic'), (1,'Döner Special',1,'menu'),
(1,'Rigatoni broccoli',1,'menu'), (1,'Spinach',1,'menu, halal, kosher'), (1,'Veggie Casserole',1,'menu'),
(1,'Burger Cola Offer',1,'menu'), (1,'Chicken Spinach',1,'menu'), (1,'Mantaplatte',1,'menu'),
(1,'Mozzarella al Forno',1,'menu'), (1,'Lasagne',1,'menu, meat'), (1,'Döner Schnitzel',1,'menu, meat'),
(1,'Rustica',1,'menu, pizza'), (1,'Chicken Curry',1,'menu'), (1,'Pizzabrötchen Döner',1,'menu'), (1,'Margherita',1,'menu'),
(1,'Mozzarella',1,'menu, pizza'), (1,'Balkan sausage',1,'menu'), (1,'Döner Hollandaise',1,'menu'), (1,'Carbonara',1,'menu'),
(1,'Calzone',1,'menu'), (1,'Salad',1,'menu, diet, healthy'), (1,'Salad Chicken',1,'menu, diet, healthy'), 
(1,'Salad Hawaii',1,'menu, diet, healthy'), (1,'Döner',1,'menu'),(1,'Prosciutto', 1, 'menu, pizza'),
(1,'Ham pizza rolls',1,'menu'), (1,'Tonno e Cipolla',1,'menu'), (1,'Hollandaise',1,'menu'),
(1,'Sauces Portions',1,'menu'), (1,'Mantaplatte Spezial',1,'menu'), (1,'Pizza rolls Margherita',1,'menu'),
(1,'Funghi',1,'menu'), (1,'Holsteiner Schnitzel',1,'menu'), (1,'Gamberetti',1,'menu'),
(1,'Salad de la Casa',1,'menu, diet, healthy'), (1,'Döner Calzone',1,'menu'), (1,'Salad Tonno',1,'menu, diet, healthy'),
(1,'Deliciosa',1,'menu'), (1,'Chili Chicken scharf',1,'menu'), (1,'Falafel Teller',1,'menu'),
(1,'Full House Angebot',1,'menu'), (1,'Pizza nach Wunsch',1,'menu'), (1,'Veggie Biryani',1,'menu'),
(1,'Portion Reis',1,'menu'), (1,'Croquettes',1,'menu'), (1,'Veggie Burger',1,'menu'),
(1,'Crispy Chicken Burger',1,'menu'), (1,'Della Casa',1,'menu'),(1,'Hawaii', 1, 'menu, pizza'),(1,'Italia', 1, 'menu, pizza'),
(1,'Various red/white wines',1,'drink, alcoholic, red wine, white wine'),(1,'Spinaci', 1, 'menu, vegetarian'), 
(1,'Veggie',1,'menu, pizza, veggie, vegetarian, halal, kosher'),(1,'Napoli',1,'menu, vegetarian, halal, kosher, tomatoes, onions, garlic, basil, oregano, parsley'), (1,'Chicken Hollandaise',1,'menu'),
(1,'Alla Panna',1,'menu'), (1,'Döner Teller',1,'menu'), (1,'Schnitzel Wiener Art',1,'menu'),
(1,'Plain pizza rolls',1,'menu'), (1,'Salad Spezial',1,'menu, diet, healthy'), (1,'Hamburger',1,'menu, burger, hamburger'),
(1,'Chicken Nuggets Teller',1,'menu'), (1,'Chicken Biryani',1,'menu'), (1,'Schnitzel Hawaii',1,'menu'),
(1,'Falafel Pocket',1,'menu, veggie, vegetarian, halal, kosher'), (1,'Veggie pizza rolls',1,'menu'), (1,'Gourmet Pot',1,'menu'),
(1,'Broccoli schnitzel',1,'menu'), (1,'Döner plate and cola offer',1,'menu'), (1,'Doner kebab',1,'menu'),
(1,'4 Seasons',1,'menu'), (1,'Mixed salad',1,'menu, diet, healthy'), (1,'Bowl of Salad',1,'menu, diet, healthy'), (1,'Doner kebab casserole',1,'menu'),
(1,'Tuna pizza rolls',1,'menu'), (1,'Pasta of your choice, canned, on offer',1,'menu'), (1,'Special',1,'menu'),
(1,'Balkan Schnitzel',1,'menu'), (1,'Tris di Pasta',1,'menu'), (1,'Salami',1,'menu'), (1,'Chicken Masala',1,'menu'),
(1,'Chicken Mushroom',1,'menu'), (1,'Veltins',1,'drink, beer, alcohol'), (1,'Mezzo Mix',1,'drink, non-alcoholic, non alcoholic'), (1,'Teenager Angebot gemicht',1,'menu'),
(1,'Hunter''s schnitzel',1,'menu'), (1,'Cream schnitzel',1,'menu'), (1,'Curry casserole',1,'menu'),
(1,'Fries',1,'menu, French fries, potato chips, veggie, vegetarian, halal, kosher'), (1,'Hunter''s sausage',1,'menu');
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_enrichments;