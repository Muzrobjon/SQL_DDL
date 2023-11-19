-- Creating the "sales_revenue_by_category_qtr" view:
CREATE VIEW sales_revenue_by_category_qtr AS
SELECT
    c.name AS category,
    SUM(p.amount) AS total_sales_revenue
FROM
    cate c
    INNER JOIN film_category fc ON c.category_id = fc.category_id
    INNER JOIN inventory i ON fc.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
WHERE
    EXTRACT(QUARTER FROM p.payment_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    c.name;
	
-- Creating the query language function "get_sales_revenue_by_category_qtr":
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(in_quarter INT)
RETURNS TABLE (category TEXT, total_sales_revenue NUMERIC)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.name AS category,
        SUM(p.amount) AS total_sales_revenue
    FROM
        category c
        INNER JOIN film_category fc ON c.category_id = fc.category_id
        INNER JOIN inventory i ON fc.film_id = i.film_id
        INNER JOIN rental r ON i.inventory_id = r.inventory_id
        INNER JOIN payment p ON r.rental_id = p.rental_id
    WHERE
        EXTRACT(QUARTER FROM p.payment_date) = in_quarter
        AND EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY
        c.name;
END;
$$ LANGUAGE plpgsql;

-- Creating the procedure language function "new_movie":
CREATE OR REPLACE FUNCTION new_movie(in_title TEXT)
RETURNS VOID
AS $$
BEGIN
    -- Generate a new unique film ID
    DECLARE new_film_id INT;
    SELECT MAX(film_id) + 1 INTO new_film_id FROM film;

    -- Insert a new movie with the given title
    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, in_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), (SELECT language_id FROM language WHERE name = 'Klingon'));

    -- Verify that the language exists in the "language" table
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid language';
    END IF;
END;
$$ LANGUAGE plpgsql;