CREATE SCHEMA BuzzBid_2;
USE BuzzBid_2;

-- Tables
CREATE TABLE `User` (
	username varchar(50) NOT NULL,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    `password` varchar(15) NOT NULL,
    PRIMARY KEY (username)
);

CREATE TABLE AdministrativeUser (
	username varchar(50) NOT NULL,
    position varchar(100) NOT NULL,
    PRIMARY KEY (username)
);


CREATE TABLE Item (
    itemID int unsigned NOT NULL AUTO_INCREMENT,
    item_name varchar(250) NOT NULL,
    item_description varchar(250) NOT NULL,
	item_condition enum('New', 'Very Good', 'Good', 'Fair', 'Poor') NOT NULL,  
	returnable boolean NOT NULL,
	starting_bid decimal(10, 2) NOT NULL,
    min_sale_price decimal(10, 2) NOT NULL,
    auction_end_time datetime NOT NULL,
    get_it_now_price decimal(10, 2) NULL, 
    listeduser varchar(50) NOT NULL,
    category_name varchar(50) NOT NULL,
    cancelled_username varchar(50) NULL,
    cancelled_reason varchar(250) NULL,
    PRIMARY KEY (itemID)
);

 -- Seperate category table for in case Database Administrator can change it 
CREATE TABLE Category (
    category_name varchar(50) NOT NULL,
    PRIMARY KEY (category_name)
);

CREATE TABLE Bid (
    itemID int unsigned NOT NULL,
	bid_amount decimal(10, 2) NOT NULL,
    time_of_bid datetime NOT NULL, 
    username varchar(50) NULL,
    PRIMARY KEY (itemID, bid_amount) 
);

CREATE TABLE Rating (
    itemID int unsigned NOT NULL,
    rating_date_time datetime NOT NULL, 
    star int NOT NULL,
    `comment` varchar(250) NULL,
    PRIMARY KEY (itemID, rating_date_time) 
);

SELECT `password` FROM `User` WHERE username= 'jay23';

-- Constraints
ALTER TABLE AdministrativeUser
    ADD CONSTRAINT fk_AdministrativeUser_username_User_username
    FOREIGN KEY (username) 
    REFERENCES User(username)
    ON UPDATE CASCADE ON DELETE CASCADE;
    
ALTER TABLE Item
    ADD CONSTRAINT fk_Item_category_name_Category_category_name 
    FOREIGN KEY (category_name) 
    REFERENCES Category(category_name)
    ON UPDATE CASCADE;

ALTER TABLE Item
    ADD CONSTRAINT fk_Item_listeduser_User_username 
    FOREIGN KEY (listeduser) 
    REFERENCES `User`(username)
    ON UPDATE CASCADE;

ALTER TABLE Item
    ADD CONSTRAINT fk_Item_cancelled_username_User_username
    FOREIGN KEY (cancelled_username) 
    REFERENCES AdministrativeUser(username)
    ON UPDATE CASCADE;

ALTER TABLE Bid
    ADD CONSTRAINT fk_Bid_username_User_username 
    FOREIGN KEY (username) 
    REFERENCES User(username)
    ON UPDATE CASCADE;
    
ALTER TABLE Bid
    ADD CONSTRAINT fk_Bid_itemID_Item_itemID 
    FOREIGN KEY (itemID) 
    REFERENCES Item(itemID)
    ON DELETE CASCADE;
    
ALTER TABLE Rating
    ADD CONSTRAINT fk_Rating_itemID_Item_itemID 
    FOREIGN KEY (itemID) 
    REFERENCES Item(itemID)
    ON DELETE CASCADE;
    
ALTER TABLE Rating
    ADD CONSTRAINT star_check CHECK (star >= 0 AND star <= 5);
    
    
INSERT INTO User (username, first_name,last_name,password) 
VALUES 
	('jay23', 'Jay', 'Vu', 'house'),
    ('ari123', 'Arianna', 'Dave', 'bicycle'),
    ('vn45', 'Vy', 'Nguyen', 'helloworld');

INSERT INTO AdministrativeUser (username, position) 
VALUES 
	('jay23', 'Admin'),
	('trups', 'engineer');

INSERT INTO Category (category_name ) 
VALUES 
	('Art'),
    ('Books'),
    ('Electronics'),
    ('Home & Gardens'),
    ('Sporting Goods'),
    ('Toys'),
    ('Other');


INSERT INTO Item (item_name, item_description, item_condition, returnable, starting_bid, min_sale_price, auction_end_time, get_it_now_price, listeduser, category_name, cancelled_username, cancelled_reason)  
VALUES   
    -- ('dish soap', 'detergent to wash dishes', 'New', True, 10.00, 8.00, '2012-12-21 11:00:00', 3, 'jay23', 'Home & Gardens', 'jay23','broken');   
    ('baseball hat', 'a baseball hat bla bla', 'Good', False, 50.00, 45.00, '2013-12-21 23:59:59', 5,'ari123' , 'Sporting Goods', NULL ,'notlike'); 
    ('TV', 'a big screen showing interesting things', 'Fair', True, 1000.00, 850.00, '2014-12-21 10:00:00', 5,'jay23', 'Electronics','jay23','doesnot gone fit'),  
    ('a', 'ghsjahgs', 'New', True, 5.00, 8.00, '2015-12-21 12:00:00', 3,'ari123' ,'Home & Gardens','ari123','toobad color'),     
    ('b', 'smfgkda', 'Good', False, 30.00, 45.00, '2016-12-21 20:00:00', 5, 'vn45', 'Sporting Goods', 'vn45','got cheeper'),  
    ('c', 'ehgwrlshsd', 'Fair', True, 1000.00, 850.00, '2017-12-21 19:00:00', 5, 'vn45', 'Electronics', 'vn45','boughtnew one');

SELECT * FROM Item;
SELECT * FROM User;

INSERT INTO Bid (itemID, username, time_of_bid, bid_amount) 
VALUES 
	(3, 'jay23', '2024-03-10 12:30:00', 1500.00),
    (4, 'ari123', '2024-03-05 09:30:00', 2000.00),
    (5, 'vn45', '2024-03-08 10:30:00', 1800.00);
TRUNCATE TABLE Item;
    
INSERT INTO Rating (ItemId, comment,rating_date_time,star) 
VALUES  
    (3, 'nice',  '2024-03-10 11:30:00', 4),
    (4, 'Good',  '2024-02-11 09:30:00', 3),
    (5, 'Fair',  '2024-01-12 10:30:00', 2);

DROP TABLE Rating;
SELECT * FROM  Bid;
SELECT * FROM  Rating;

SELECT COUNT(DISTINCT itemID) as 'ID',
	   listeduser as 'Listed by',
       auction_end_time as 'Cancelled Date' ,
       cancelled_reason as 'Reason'
FROM Item 
WHERE cancelled_username IS NOT NULL
group by itemId
order by itemId desc;

SELECT COUNT(auction_end_time) AS 'Auctions Active' FROM Item WHERE auction_end_time > NOW() AND cancelled_username IS NULL ;

SELECT COUNT(auction_end_time) AS 'Auctions Finished' FROM Item WHERE auction_end_time <= NOW() AND cancelled_username IS NULL;

SELECT COUNT(DISTINCT i.itemID) as 'Auctions Won'
        FROM Item i
        JOIN Bid b ON i.itemID = b.itemID
        WHERE i.auction_end_time <= NOW()
        AND i.get_it_now_price <= b.bid_amount
        AND i.cancelled_username IS NULL ;

SELECT COUNT(itemID) as 'Auctions Cancelled' FROM Item WHERE cancelled_username IS NOT NULL;

SELECT COUNT(DISTINCT itemID) AS 'Items Rated' FROM Rating ;

SELECT COUNT(DISTINCT itemID) as 'Items Not Rated' from Item where itemID NOT IN (SELECT DISTINCT itemID FROM Rating)

SELECT 
    category_name,
    COUNT(itemID) as item_count,  
    MIN(CASE WHEN get_it_now_price IS NOT NULL THEN get_it_now_price END) as min_get_it_now_price,  
    MAX(CASE WHEN get_it_now_price IS NOT NULL THEN get_it_now_price END) as max_get_it_now_price,  
    AVG(CASE WHEN get_it_now_price IS NOT NULL  THEN get_it_now_price END) as avg_get_it_now_price  
FROM 
    item
WHERE 
    cancelled_username is null
GROUP BY 
    category_name
ORDER BY 
    category_name asc;
    
    
    
SELECT 
    CASE 
        WHEN au.username IS NOT NULL THEN 'cancelled'
        ELSE CAST(b.bid_amount AS CHAR)
    END AS 'Bid Amount',
    b.time_of_bid AS 'Time of Bid',
    b.username AS 'Username'
FROM bid b
LEFT JOIN AdministrativeUser au ON b.username = au.username
WHERE b.itemID = 3
ORDER BY b.time_of_bid DESC;


SELECT i1.itemID AS 'ID', i1.item_name AS 'Item Name', 
	CASE
		WHEN i1.cancelled_reason IS NULL THEN b1.bid_amount
ELSE NULL
	END AS 'Sale Price',
	CASE
		WHEN i1.cancelled_reason IS NULL THEN b1.username
ELSE 'Cancelled'
	END AS 'Winner',
    i1.auction_end_time AS 'Auction Ended'
FROM Item i1 LEFT JOIN (
	SELECT b2.itemID, b2.username, b2.bid_amount FROM Bid b2 INNER JOIN (
		SELECT itemID, MAX(bid_amount) AS MaxBid FROM Bid GROUP BY itemID
	) AS MaxBids ON b2.itemID = MaxBids.itemID AND b2.bid_amount = MaxBids.MaxBid
) b1 ON i1.itemID = b1.itemID
WHERE i1.auction_end_time<= NOW() AND b1.bid_amount >= i1.min_sale_price OR b1.bid_amount IS NULL
ORDER BY i1.auction_end_time DESC;

UPDATE Item SET item_description = 'a big screen showing interesting things'
WHERE itemID = 3;
SELECT * FROM  Item;

UPDATE Item 
SET auction_end_time=NOW(),
        cancelled_username='trups',
        cancelled_reason='notgood'
 WHERE itemID = 3;


INSERT INTO Bid (itemID, username,time_of_bid,bid_amount) 
VALUES (21, 'trups', NOW(), 210);
INSERT INTO Bid (itemID, username,time_of_bid,bid_amount) 
VALUES (21, 'jay23', NOW(), 39);


UPDATE Item SET auction_end_time=NOW() WHERE itemID=3;

SELECT username FROM AdministrativeUser WHERE username='vn45';

SELECT * FROM AdministrativeUser;

SELECT * FROM Bid;

SELECT listeduser FROM Item WHERE itemID=11;

SELECT MAX(bid_amount) AS 'MaxBid' FROM Bid WHERE itemID=3 GROUP BY itemID;

SELECT bid_amount AS 'Bid Amount', time_of_bid AS 'Time of Bid', username AS 'Username'  FROM Bid WHERE itemID= 3 ORDER BY bid_amount DESC LIMIT 4;

SELECT itemID, item_name, item_description, category_name, item_condition, returnable, get_it_now_price, auction_end_time from Item WHERE itemID=20;


SELECT 
i1.itemID AS ID,
i1.item_name AS 'Item Name', 
b1.bid_amount AS 'Current Bid', 
b1.username AS 'High Bidder', 
i1.get_it_now_price AS 'Get It Now Price', 
i1.auction_end_time AS 'Auction Ends'
FROM 
Item i1 
LEFT JOIN (
SELECT b.itemID, b.bid_amount, b.username 
FROM Bid b 
INNER JOIN (
		SELECT itemID, MAX(bid_amount) AS MaxBid 
		FROM Bid 
GROUP BY itemID
) AS MaxBids ON b.itemID = MaxBids.itemID AND b.bid_amount = MaxBids.MaxBid
) AS b1 ON Item.itemID = b1.itemID 
WHERE 
Item.itemID IN (
		SELECT Item.itemID 
FROM Item 
LEFT JOIN Bid ON Item.itemID = Bid.itemID
		WHERE 
('$keyword' IS NULL OR BINARY item_name LIKE CONCAT('%', '$keyword', '%') OR BINARY item_description LIKE CONCAT('%', '$keyword', '%'))
			AND ('$category' IS NULL OR category_name = '$category')
		AND ($min_price IS NULL OR (SELECT MAX(bid_amount) FROM Bid WHERE Item.itemID = Bid.itemID) >= $min_price OR starting_bid >= $min_price)
			AND ($max_price IS NULL OR (SELECT MAX(bid_amount) FROM Bid WHERE Item.itemID = Bid.itemID) <= $max_price OR starting_bid <= $max_price)
		AND ('$condition' IS NULL OR item_condition >= '$condition')
	GROUP BY Item.itemID
);


SELECT category_name from Category;

