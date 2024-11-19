CREATE DATABASE IF NOT EXISTS P101_06_challange1_nba;
USE P101_06_challange1_nba;

-- Drop tables if they exist to avoid conflicts
DROP TABLE IF EXISTS Ticket, TicketSeller, SecurityGuard, Bartender, Cleaner, Mascot, Staff, Seat, Zone, `Match`, Franchise_Season, RegularSeason, Player_Franchise, DraftProcess, Draft, NationalTeam_Player, NationalTeam, AssistantCoach, Franchise, Stadium, Conference, HeadCoach, Player, Person;

-- tables are created in order so that foreign keys can be done without ALTER commands
CREATE TABLE IF NOT EXISTS Person (
    id_card VARCHAR(20) PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    nationality VARCHAR(50),
    gender ENUM('M', 'F') DEFAULT 'M',
    birthdate DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Player (
    id_card_player VARCHAR(20) PRIMARY KEY,
    pro_year INT UNSIGNED,
    university VARCHAR(100),
    num_championships INT UNSIGNED DEFAULT 0,
    FOREIGN KEY (id_card_player) REFERENCES Person(id_card)
);

CREATE TABLE IF NOT EXISTS HeadCoach (
    id_card_head_coach VARCHAR(20) PRIMARY KEY,
    victories_percent DECIMAL(5, 2) DEFAULT 0.00,
    salary DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (id_card_head_coach) REFERENCES Person(id_card)
);

CREATE TABLE IF NOT EXISTS Conference (
    `name` VARCHAR(50) PRIMARY KEY,
    location VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Stadium (
    arena_name VARCHAR(50) PRIMARY KEY,
    city VARCHAR(100),
    capacity INT UNSIGNED
);

CREATE TABLE IF NOT EXISTS Franchise (
	`name` VARCHAR(50) PRIMARY KEY,
    city VARCHAR(100),
    annual_budget DECIMAL(15, 2),
    amount_rings INT UNSIGNED DEFAULT 0,
    head_coach VARCHAR(20), 
    conference VARCHAR(50),
    arena_name VARCHAR(50),
    FOREIGN KEY (head_coach) REFERENCES HeadCoach(id_card_head_coach),
    FOREIGN KEY (conference) REFERENCES Conference(`name`),
    FOREIGN KEY (arena_name) REFERENCES Stadium(arena_name)
);

CREATE TABLE IF NOT EXISTS AssistantCoach (
    id_card_ass_coach VARCHAR(20) PRIMARY KEY,
    speciality VARCHAR(50),
    franchise_name VARCHAR(50),
    FOREIGN KEY (id_card_ass_coach) REFERENCES Person(id_card),
    FOREIGN KEY (franchise_name) REFERENCES Franchise(`name`)
);

CREATE TABLE IF NOT EXISTS NationalTeam (
    roster_year INT UNSIGNED,
    country VARCHAR(50),
    head_coach VARCHAR(20),
    PRIMARY KEY (roster_year, country), -- Composite key!
    FOREIGN KEY (head_coach) REFERENCES HeadCoach(id_card_head_coach)
);

CREATE TABLE IF NOT EXISTS NationalTeam_Player (
	player_id VARCHAR(20),
    `year` INT UNSIGNED,
    country VARCHAR(50),
    PRIMARY KEY (player_id, `year`, country),
	FOREIGN KEY (player_id) REFERENCES Player(id_card_player),
	FOREIGN KEY (`year`, country) REFERENCES NationalTeam(roster_year, country)
);

CREATE TABLE IF NOT EXISTS Draft (
    `year` INT UNSIGNED PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS DraftProcess (
    player_id VARCHAR(20),
    draft_year INT UNSIGNED,
    franchise_name VARCHAR(50),
    rank_player INT UNSIGNED,
    PRIMARY KEY (player_id, draft_year, franchise_name),
    FOREIGN KEY (player_id) REFERENCES Player(id_card_player),
    FOREIGN KEY (draft_year) REFERENCES Draft(`year`),
    FOREIGN KEY (franchise_name) REFERENCES Franchise(`name`)
);

CREATE TABLE IF NOT EXISTS Player_Franchise (
    player_id VARCHAR(20),
    franchise_name VARCHAR(50),
    salary DECIMAL(12, 2),
    year_in INT UNSIGNED,
    year_out INT UNSIGNED,
    shirt_num INT UNSIGNED,
	PRIMARY KEY(player_id, franchise_name),
    FOREIGN KEY (player_id) REFERENCES Player(id_card_player),
    FOREIGN KEY (franchise_name) REFERENCES Franchise(`name`)
);

CREATE TABLE IF NOT EXISTS RegularSeason (
    `year` INT UNSIGNED PRIMARY KEY,
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS Franchise_Season (
	franchise_name VARCHAR(50),
    `year` INT UNSIGNED,
    is_winner BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (franchise_name, `year`),
    FOREIGN KEY (franchise_name) REFERENCES Franchise(`name`),
    FOREIGN KEY (`year`) REFERENCES RegularSeason(`year`)
);

CREATE TABLE IF NOT EXISTS `Match` (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    match_date DATE,
    local_points INT UNSIGNED,
    visitor_points INT UNSIGNED,
    local_team VARCHAR(50),
    visitor_team VARCHAR(50),
    MVPlayer_id VARCHAR(20),
    arena_name VARCHAR(50),
    FOREIGN KEY (local_team) REFERENCES Franchise(`name`),
    FOREIGN KEY (visitor_team) REFERENCES Franchise(`name`),
    FOREIGN KEY (MVPlayer_id) REFERENCES Player(id_card_player),
    FOREIGN KEY (arena_name) REFERENCES Stadium(arena_name)
);

CREATE TABLE IF NOT EXISTS Zone (
    zone_code VARCHAR(20), -- might include letters, as in the picture of the assignment
    arena_name VARCHAR(50),
    is_vip BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (zone_code, arena_name),
    FOREIGN KEY (arena_name) REFERENCES Stadium(arena_name)
);

CREATE TABLE IF NOT EXISTS Seat (
    seat_number INT UNSIGNED,
    zone_code VARCHAR(20),
    arena_name VARCHAR(50),
    color VARCHAR(50),
    PRIMARY KEY (seat_number, zone_code, arena_name),
    FOREIGN KEY (zone_code, arena_name) REFERENCES Zone(zone_code, arena_name)
);

CREATE TABLE IF NOT EXISTS Staff (
    national_id VARCHAR(20) PRIMARY KEY,
    birthdate DATE,
    city_residence VARCHAR(100),
    account_num VARCHAR(50),
    contract_type ENUM('Full-Time', 'Part-Time') DEFAULT 'Full-Time',
    franchise_name VARCHAR(50),
	FOREIGN KEY (franchise_name) REFERENCES Franchise(`name`)
);

CREATE TABLE IF NOT EXISTS Mascot (
    mascot_id VARCHAR(20) PRIMARY KEY,
    custom_animal VARCHAR(50),
    FOREIGN KEY (mascot_id) REFERENCES Staff(national_id)
);

CREATE TABLE IF NOT EXISTS Cleaner (
    cleaner_id VARCHAR(20) PRIMARY KEY,
    speed DECIMAL(5, 2),
    FOREIGN KEY (cleaner_id) REFERENCES Staff(national_id)
);

CREATE TABLE IF NOT EXISTS Bartender (
    bartender_id VARCHAR(20) PRIMARY KEY,
    has_alcohol_record BOOLEAN, -- don't assume FALSE by default
    FOREIGN KEY (bartender_id) REFERENCES Staff(national_id)
);

CREATE TABLE IF NOT EXISTS SecurityGuard (
    security_guard_id VARCHAR(20) PRIMARY KEY,
    gun_license BOOLEAN, -- don't assume TRUE by default
    arena_name VARCHAR(50),
    FOREIGN KEY (security_guard_id) REFERENCES Staff(national_id),
    FOREIGN KEY (arena_name) REFERENCES Stadium(arena_name)
);

CREATE TABLE IF NOT EXISTS TicketSeller (
    ticket_seller_id VARCHAR(20) PRIMARY KEY,
    is_gambler BOOLEAN, -- don't assume FALSE by default
    FOREIGN KEY (ticket_seller_id) REFERENCES Staff(national_id)
);

CREATE TABLE IF NOT EXISTS Ticket (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    selling_date DATE,
    price DECIMAL(7,2),
    is_vip_ticket BOOLEAN DEFAULT FALSE,
    seat_number INT UNSIGNED,
    zone_code VARCHAR(20),
    arena_name VARCHAR(50),
    ticket_seller VARCHAR(20),
    match_id INT,
    FOREIGN KEY (seat_number, zone_code, arena_name) REFERENCES Seat(seat_number, zone_code, arena_name),
    FOREIGN KEY (ticket_seller) REFERENCES TicketSeller(ticket_seller_id),
    FOREIGN KEY (match_id) REFERENCES `Match`(match_id)
);