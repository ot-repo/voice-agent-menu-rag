-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_enrichments
(
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    client_id INT NOT NULL REFERENCES clients(id), --  0 for the enrichments common to all customers
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
(0,'Snack dishes',2,NULL), (0,'Offers',2,NULL), (0,'Salads',2,NULL), (0,'Burger',2,NULL),
(0,'Pasta',2,NULL), (0,'Voucher for sale',2,NULL), (0,'Stuffed pizza rolls',2,NULL),
(0,'Schnitzel',2,NULL), (0,'delivery costs',2,NULL), (0,'Doner dishes',2,NULL), (0,'Casseroles',2,NULL),
(0,'Pizza',2,NULL), (0,'Indian',2,NULL), (0,'Drinks',2,'alcoholic, non-alcoholic, soft drink'),
(0,'delivery costs',1,NULL), (0,'Ketchup',1,NULL), (0,'Herbal cream',1,NULL), (0,'Mayonnaise',1,NULL),
(0,'Naan bread',1,NULL), (0,'40% discount voucher',1,NULL),
(0,'Sprite',1,'Sprite, zero-sugar carbonated soft drink, carbonated beverage, lemon-lime flavored, non-alcoholic, non alcoholic'),
(0,'Coca Cola light',1,'Coca Cola light, diet Coke, soft drink, beverage, non-alcoholic, non alcoholic'),
(0,'Salami pizza rolls',1,'menu'), (0,'Farmer''s Salad',1,'menu, diet, healthy'),
(0,'6 Chicken Nuggets ',1,'menu, chicken nuggets, chicken bites, high protein, fast food, precooked, white meat, ready-to-eat, pack of 6'),
(0,'Bolognese',1,'menu, spaghetti, red meat, non-vegetarian,pasta, tomato, onion, garlic'),
(0,'Ayran',1,'Turkish ayran, yogurt drink, dairy drink, non-alcoholic, non alcoholic'),
(0,'Fanta',1,'Fanta, carbonated soft drink, beverage, citrus-flavored, non-alcoholic, non alcoholic'),
(0,'Bottle of vodka',1,'vodka, alcohol, drink'), (0,'Bottle of whisky',1,'whisky, alcohol, drink'),
(0,'Coca Cola',1,'Coca Cola, Coke, soft drink, beverage, non-alcoholic, non alcoholic'), (0,'Döner Special',1,'menu'),
(0,'Rigatoni broccoli',1,'menu'), (0,'Spinach',1,'menu, halal, kosher'), (0,'Veggie Casserole',1,'menu'),
(0,'Burger Cola Offer',1,'menu'), (0,'Chicken Spinach',1,'menu'), (0,'Mantaplatte',1,'menu'),
(0,'Mozzarella al Forno',1,'menu'), (0,'Lasagne',1,'menu, meat'), (0,'Döner Schnitzel',1,'menu, meat'),
(0,'Rustica',1,'menu, pizza'), (0,'Chicken Curry',1,'menu'), (0,'Pizzabrötchen Döner',1,'menu'), (0,'Margherita',1,'menu'),
(0,'Mozzarella',1,'menu, pizza'), (0,'Balkan sausage',1,'menu'), (0,'Döner Hollandaise',1,'menu'), (0,'Carbonara',1,'menu'),
(0,'Calzone',1,'menu'), (0,'Salad',1,'menu, diet, healthy'), (0,'Salad Chicken',1,'menu, diet, healthy'), 
(0,'Salad Hawaii',1,'menu, diet, healthy'), (0,'Döner',1,'menu'),(0, 'Prosciutto', 1, 'menu, pizza'),
(0,'Ham pizza rolls',1,'menu'), (0,'Tonno e Cipolla',1,'menu'), (0,'Hollandaise',1,'menu'),
(0,'Sauces Portions',1,'menu'), (0,'Mantaplatte Spezial',1,'menu'), (0,'Pizza rolls Margherita',1,'menu'),
(0,'Funghi',1,'menu'), (0,'Holsteiner Schnitzel',1,'menu'), (0,'Gamberetti',1,'menu'),
(0,'Salad de la Casa',1,'menu, diet, healthy'), (0,'Döner Calzone',1,'menu'), (0,'Salad Tonno',1,'menu, diet, healthy'),
(0,'Deliciosa',1,'menu'), (0,'Chili Chicken scharf',1,'menu'), (0,'Falafel Teller',1,'menu'),
(0,'Full House Angebot',1,'menu'), (0,'Pizza nach Wunsch',1,'menu'), (0,'Veggie Biryani',1,'menu'),
(0,'Portion Reis',1,'menu'), (0,'Croquettes',1,'menu'), (0,'Veggie Burger',1,'menu'),
(0,'Crispy Chicken Burger',1,'menu'), (0,'Della Casa',1,'menu'),(0, 'Hawaii', 1, 'menu, pizza'),(0, 'Italia', 1, 'menu, pizza'),
(0,'Various red/white wines',1,'drink, alcoholic, red wine, white wine'),(0, 'Spinaci', 1, 'menu, vegetarian'), 
(0,'Veggie',1,'menu, pizza, veggie, vegetarian, halal, kosher'),(0,'Napoli',1,'menu, vegetarian, halal, kosher, tomatoes, onions, garlic, basil, oregano, parsley'), (0,'Chicken Hollandaise',1,'menu'),
(0,'Alla Panna',1,'menu'), (0,'Döner Teller',1,'menu'), (0,'Schnitzel Wiener Art',1,'menu'),
(0,'Plain pizza rolls',1,'menu'), (0,'Salad Spezial',1,'menu, diet, healthy'), (0,'Hamburger',1,'menu, burger, hamburger'),
(0,'Chicken Nuggets Teller',1,'menu'), (0,'Chicken Biryani',1,'menu'), (0,'Schnitzel Hawaii',1,'menu'),
(0,'Falafel Pocket',1,'menu, veggie, vegetarian, halal, kosher'), (0,'Veggie pizza rolls',1,'menu'), (0,'Gourmet Pot',1,'menu'),
(0,'Broccoli schnitzel',1,'menu'), (0,'Döner plate and cola offer',1,'menu'), (0,'Doner kebab',1,'menu'),
(0,'4 Seasons',1,'menu'), (0,'Mixed salad',1,'menu, diet, healthy'), (0,'Bowl of Salad',1,'menu, diet, healthy'), (0,'Doner kebab casserole',1,'menu'),
(0,'Tuna pizza rolls',1,'menu'), (0,'Pasta of your choice, canned, on offer',1,'menu'), (0,'Special',1,'menu'),
(0,'Balkan Schnitzel',1,'menu'), (0,'Tris di Pasta',1,'menu'), (0,'Salami',1,'menu'), (0,'Chicken Masala',1,'menu'),
(0,'Chicken Mushroom',1,'menu'), (0,'Veltins',1,'drink, beer, alcohol'), (0,'Mezzo Mix',1,'drink, non-alcoholic, non alcoholic'), (0,'Teenager Angebot gemicht',1,'menu'),
(0,'Hunter''s schnitzel',1,'menu'), (0,'Cream schnitzel',1,'menu'), (0,'Curry casserole',1,'menu'),
(0,'Fries',1,'menu, French fries, potato chips, veggie, vegetarian, halal, kosher'), (0,'Hunter''s sausage',1,'menu');
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_enrichments;