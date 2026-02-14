-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_enrichments
(
    id SERIAL PRIMARY KEY,
    customer_id CHAR(36) NOT NULL, --  00000000-0000-0000-0000-000000000000 for the enrichments common to all customers
    item VARCHAR(100) NOT NULL,
    type SMALLINT NOT NULL, -- 1: product; 2: category
    synonyms VARCHAR NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);

-- Add other indexes here
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_enrichments_customer_id_type_item_deleted_at ON menu_enrichments(customer_id, type, item) WHERE deleted_at IS NULL;

INSERT INTO menu_enrichments (customer_id,item,"type",synonyms) VALUES
('00000000-0000-0000-0000-000000000000','Snack dishes',2,NULL), ('00000000-0000-0000-0000-000000000000','Offers',2,NULL), ('00000000-0000-0000-0000-000000000000','Salads',2,NULL), ('00000000-0000-0000-0000-000000000000','Burger',2,NULL),
('00000000-0000-0000-0000-000000000000','Pasta',2,NULL), ('00000000-0000-0000-0000-000000000000','Voucher for sale',2,NULL), ('00000000-0000-0000-0000-000000000000','Stuffed pizza rolls',2,NULL),
('00000000-0000-0000-0000-000000000000','Schnitzel',2,NULL), ('00000000-0000-0000-0000-000000000000','delivery costs',2,NULL), ('00000000-0000-0000-0000-000000000000','Doner dishes',2,NULL), ('00000000-0000-0000-0000-000000000000','Casseroles',2,NULL),
('00000000-0000-0000-0000-000000000000','Pizza',2,NULL), ('00000000-0000-0000-0000-000000000000','Indian',2,NULL), ('00000000-0000-0000-0000-000000000000','Drinks',2,'alcoholic, non-alcoholic, soft drink'),
('00000000-0000-0000-0000-000000000000','delivery costs',1,NULL), ('00000000-0000-0000-0000-000000000000','Ketchup',1,NULL), ('00000000-0000-0000-0000-000000000000','Herbal cream',1,NULL), ('00000000-0000-0000-0000-000000000000','Mayonnaise',1,NULL),
('00000000-0000-0000-0000-000000000000','Naan bread',1,NULL), ('00000000-0000-0000-0000-000000000000','40% discount voucher',1,NULL),
('00000000-0000-0000-0000-000000000000','Sprite',1,'Sprite, zero-sugar carbonated soft drink, carbonated beverage, lemon-lime flavored, non-alcoholic, non alcoholic'),
('00000000-0000-0000-0000-000000000000','Coca Cola light',1,'Coca Cola light, diet Coke, soft drink, beverage, non-alcoholic, non alcoholic'),
('00000000-0000-0000-0000-000000000000','Salami pizza rolls',1,'menu'), ('00000000-0000-0000-0000-000000000000','Farmer''s Salad',1,'menu, diet, healthy'),
('00000000-0000-0000-0000-000000000000','6 Chicken Nuggets ',1,'menu, chicken nuggets, chicken bites, high protein, fast food, precooked, white meat, ready-to-eat, pack of 6'),
('00000000-0000-0000-0000-000000000000','Bolognese',1,'menu, spaghetti, red meat, non-vegetarian,pasta, tomato, onion, garlic'),
('00000000-0000-0000-0000-000000000000','Ayran',1,'Turkish ayran, yogurt drink, dairy drink, non-alcoholic, non alcoholic'),
('00000000-0000-0000-0000-000000000000','Fanta',1,'Fanta, carbonated soft drink, beverage, citrus-flavored, non-alcoholic, non alcoholic'),
('00000000-0000-0000-0000-000000000000','Bottle of vodka',1,'vodka, alcohol, drink'), ('00000000-0000-0000-0000-000000000000','Bottle of whisky',1,'whisky, alcohol, drink'),
('00000000-0000-0000-0000-000000000000','Coca Cola',1,'Coca Cola, Coke, soft drink, beverage, non-alcoholic, non alcoholic'), ('00000000-0000-0000-0000-000000000000','Döner Special',1,'menu'),
('00000000-0000-0000-0000-000000000000','Rigatoni broccoli',1,'menu'), ('00000000-0000-0000-0000-000000000000','Spinach',1,'menu, halal, kosher'), ('00000000-0000-0000-0000-000000000000','Veggie Casserole',1,'menu'),
('00000000-0000-0000-0000-000000000000','Burger Cola Offer',1,'menu'), ('00000000-0000-0000-0000-000000000000','Chicken Spinach',1,'menu'), ('00000000-0000-0000-0000-000000000000','Mantaplatte',1,'menu'),
('00000000-0000-0000-0000-000000000000','Mozzarella al Forno',1,'menu'), ('00000000-0000-0000-0000-000000000000','Lasagne',1,'menu, meat'), ('00000000-0000-0000-0000-000000000000','Döner Schnitzel',1,'menu, meat'),
('00000000-0000-0000-0000-000000000000','Rustica',1,'menu, pizza'), ('00000000-0000-0000-0000-000000000000','Chicken Curry',1,'menu'), ('00000000-0000-0000-0000-000000000000','Pizzabrötchen Döner',1,'menu'), ('00000000-0000-0000-0000-000000000000','Margherita',1,'menu'),
('00000000-0000-0000-0000-000000000000','Mozzarella',1,'menu, pizza'), ('00000000-0000-0000-0000-000000000000','Balkan sausage',1,'menu'), ('00000000-0000-0000-0000-000000000000','Döner Hollandaise',1,'menu'), ('00000000-0000-0000-0000-000000000000','Carbonara',1,'menu'),
('00000000-0000-0000-0000-000000000000','Calzone',1,'menu'), ('00000000-0000-0000-0000-000000000000','Salad',1,'menu, diet, healthy'), ('00000000-0000-0000-0000-000000000000','Salad Chicken',1,'menu, diet, healthy'), 
('00000000-0000-0000-0000-000000000000','Salad Hawaii',1,'menu, diet, healthy'), ('00000000-0000-0000-0000-000000000000','Döner',1,'menu'),('00000000-0000-0000-0000-000000000000', 'Prosciutto', 1, 'menu, pizza'),
('00000000-0000-0000-0000-000000000000','Ham pizza rolls',1,'menu'), ('00000000-0000-0000-0000-000000000000','Tonno e Cipolla',1,'menu'), ('00000000-0000-0000-0000-000000000000','Hollandaise',1,'menu'),
('00000000-0000-0000-0000-000000000000','Sauces Portions',1,'menu'), ('00000000-0000-0000-0000-000000000000','Mantaplatte Spezial',1,'menu'), ('00000000-0000-0000-0000-000000000000','Pizza rolls Margherita',1,'menu'),
('00000000-0000-0000-0000-000000000000','Funghi',1,'menu'), ('00000000-0000-0000-0000-000000000000','Holsteiner Schnitzel',1,'menu'), ('00000000-0000-0000-0000-000000000000','Gamberetti',1,'menu'),
('00000000-0000-0000-0000-000000000000','Salad de la Casa',1,'menu, diet, healthy'), ('00000000-0000-0000-0000-000000000000','Döner Calzone',1,'menu'), ('00000000-0000-0000-0000-000000000000','Salad Tonno',1,'menu, diet, healthy'),
('00000000-0000-0000-0000-000000000000','Deliciosa',1,'menu'), ('00000000-0000-0000-0000-000000000000','Chili Chicken scharf',1,'menu'), ('00000000-0000-0000-0000-000000000000','Falafel Teller',1,'menu'),
('00000000-0000-0000-0000-000000000000','Full House Angebot',1,'menu'), ('00000000-0000-0000-0000-000000000000','Pizza nach Wunsch',1,'menu'), ('00000000-0000-0000-0000-000000000000','Veggie Biryani',1,'menu'),
('00000000-0000-0000-0000-000000000000','Portion Reis',1,'menu'), ('00000000-0000-0000-0000-000000000000','Croquettes',1,'menu'), ('00000000-0000-0000-0000-000000000000','Veggie Burger',1,'menu'),
('00000000-0000-0000-0000-000000000000','Crispy Chicken Burger',1,'menu'), ('00000000-0000-0000-0000-000000000000','Della Casa',1,'menu'),('00000000-0000-0000-0000-000000000000', 'Hawaii', 1, 'menu, pizza'),('00000000-0000-0000-0000-000000000000', 'Italia', 1, 'menu, pizza'),
('00000000-0000-0000-0000-000000000000','Various red/white wines',1,'drink, alcoholic, red wine, white wine'),('00000000-0000-0000-0000-000000000000', 'Spinaci', 1, 'menu, vegetarian'), 
('00000000-0000-0000-0000-000000000000','Veggie',1,'menu, pizza, veggie, vegetarian, halal, kosher'),('00000000-0000-0000-0000-000000000000','Napoli',1,'menu, vegetarian, halal, kosher, tomatoes, onions, garlic, basil, oregano, parsley'), ('00000000-0000-0000-0000-000000000000','Chicken Hollandaise',1,'menu'),
('00000000-0000-0000-0000-000000000000','Alla Panna',1,'menu'), ('00000000-0000-0000-0000-000000000000','Döner Teller',1,'menu'), ('00000000-0000-0000-0000-000000000000','Schnitzel Wiener Art',1,'menu'),
('00000000-0000-0000-0000-000000000000','Plain pizza rolls',1,'menu'), ('00000000-0000-0000-0000-000000000000','Salad Spezial',1,'menu, diet, healthy'), ('00000000-0000-0000-0000-000000000000','Hamburger',1,'menu, burger, hamburger'),
('00000000-0000-0000-0000-000000000000','Chicken Nuggets Teller',1,'menu'), ('00000000-0000-0000-0000-000000000000','Chicken Biryani',1,'menu'), ('00000000-0000-0000-0000-000000000000','Schnitzel Hawaii',1,'menu'),
('00000000-0000-0000-0000-000000000000','Falafel Pocket',1,'menu, veggie, vegetarian, halal, kosher'), ('00000000-0000-0000-0000-000000000000','Veggie pizza rolls',1,'menu'), ('00000000-0000-0000-0000-000000000000','Gourmet Pot',1,'menu'),
('00000000-0000-0000-0000-000000000000','Broccoli schnitzel',1,'menu'), ('00000000-0000-0000-0000-000000000000','Döner plate and cola offer',1,'menu'), ('00000000-0000-0000-0000-000000000000','Doner kebab',1,'menu'),
('00000000-0000-0000-0000-000000000000','4 Seasons',1,'menu'), ('00000000-0000-0000-0000-000000000000','Mixed salad',1,'menu, diet, healthy'), ('00000000-0000-0000-0000-000000000000','Bowl of Salad',1,'menu, diet, healthy'), ('00000000-0000-0000-0000-000000000000','Doner kebab casserole',1,'menu'),
('00000000-0000-0000-0000-000000000000','Tuna pizza rolls',1,'menu'), ('00000000-0000-0000-0000-000000000000','Pasta of your choice, canned, on offer',1,'menu'), ('00000000-0000-0000-0000-000000000000','Special',1,'menu'),
('00000000-0000-0000-0000-000000000000','Balkan Schnitzel',1,'menu'), ('00000000-0000-0000-0000-000000000000','Tris di Pasta',1,'menu'), ('00000000-0000-0000-0000-000000000000','Salami',1,'menu'), ('00000000-0000-0000-0000-000000000000','Chicken Masala',1,'menu'),
('00000000-0000-0000-0000-000000000000','Chicken Mushroom',1,'menu'), ('00000000-0000-0000-0000-000000000000','Veltins',1,'drink, beer, alcohol'), ('00000000-0000-0000-0000-000000000000','Mezzo Mix',1,'drink, non-alcoholic, non alcoholic'), ('00000000-0000-0000-0000-000000000000','Teenager Angebot gemicht',1,'menu'),
('00000000-0000-0000-0000-000000000000','Hunter''s schnitzel',1,'menu'), ('00000000-0000-0000-0000-000000000000','Cream schnitzel',1,'menu'), ('00000000-0000-0000-0000-000000000000','Curry casserole',1,'menu'),
('00000000-0000-0000-0000-000000000000','Fries',1,'menu, French fries, potato chips, veggie, vegetarian, halal, kosher'), ('00000000-0000-0000-0000-000000000000','Hunter''s sausage',1,'menu');
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_enrichments;