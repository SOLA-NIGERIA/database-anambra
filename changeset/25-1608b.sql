--
-- PostgreSQL database dump
--
  
-- Dumped from database version 9.2.3
-- Dumped by pg_dump version 9.3.1
-- Started on 2016-08-29 14:22:17

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = administrative, pg_catalog;

--
-- TOC entry 4068 (class 0 OID 1185274)
-- Dependencies: 442
-- Data for Name: lease_condition_template; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE lease_condition_template DISABLE TRIGGER ALL;
DELETE FROM administrative.lease_condition_template;
INSERT INTO lease_condition_template (id, template_name, rrr_type, template_text, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('de162d55-2e1f-4347-b9d6-4c8a38505e23', 'Agricultural', NULL, 'This certificate of occupancy is issued subject to the following covenants and conditions being observed by the holder/holders:
(a)	To pay such compensations to the inhabitants of the area of the land which is the subject of the Certificate of Occupancy and may be fixed by the GOVERNOR or his authorized agents for the disturbances of the inhabitants in their use or occupation of the land.
(b)	During the first two years of the term of the agricultural certificate of occupancy to expend on cultivation and clearing a sum at least equivalent to N 500.00 (FIVE HUNDRED) NAIRA per hectare of the total area held under the certificate.
(c)	In each of the first eight years of the term created by the certificate of occupancy to bring into cultivation at least one-eight of the cultivable portion of the land which is subject of the said certificate, and thereafter to keep in cultivation the whole of the cultivable portion of the such land to the satisfaction of the GOVERNOR.
(d)	Should livestock be brought on the land, to erect and maintain such fences as shall prevent such stock from straying off such land.
(e)	Not to construct upon the land any dwelling-house or any permanent structure except farmhouses and legitimate dwelling-houses for farm workers and buildings to be used for storing agricultural machinery, tools or produce or for any other purpose directly connected with the carrying of cultivation, planting or farming or housing of livestock as specifically approved by the GOVERNOR.
(f)	Not to plant or erect any hut or building within fifteen meters of the centre of any main road or in the case of a highway twenty-three meters from the center of the road or in the case of an express highway, forty-five meters from the center of the express highway.
(g)	If any question shall arise as to whether any portion of the land is cultivable the decision of the GOVERNOR, if the land is within urban area, or the Local Government, if the land is outside urban area, shall be final.
(h)	All rights of inhabitants in respect of water, sacred trees and grasses of the land held under the certificate of occupancy are reserved.
(i)	The formation of labourers’ camp shall be subject to the following conditions:
i.	that officers of the Government and Local Government shall at all times have the right of access to such camps,
ii.	that the camp is kept in a thorough sanitary state, and
iii.	that no fees or rental are charged to the persons therein for their use.
(j)	When inhabitants are, at the date of the issue of the agricultural certificate of occupancy, occupying any part of the land which is the subject of the certificate of occupancy, the compensation to be paid to them by the holder of the certificate for
improvement and disturbance shall be assessed in accordance with the Act as soon as convenient after the date of the certificate of occupancy, and any such inhabitants shall have the option either:
i.	to vacate immediately the land and receive the compensation assessed, or
ii.	to remain on the land until the holder requires them to vacate or until they desire to vacate the land; and on vacating the land to receive from the holder the compensation as aforesaid, or
iii.	that no fees or rental are charged to the persons therein for their use.
Provided that the holder of the Certificate of Occupancy permits persons whether in occupation of the land at the date of the Certificate of Occupancy or allowed by the said holder subsequently to occupy any part of the land to make improvements upon the land after the date of the Certificate of Occupancy, the said holder shall be liable to pay compensation for such improvements upon requiring the persons to vacate the land.
', '19383748-5200-4e3c-ad43-a2547220e03c', 1, 'i', 'test', '2016-08-18 17:41:08.138');
INSERT INTO lease_condition_template (id, template_name, rrr_type, template_text, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('2850d4d8-e7e3-46d1-bbc2-6cda6fefd67d', 'Building', NULL, 'This certificate of occupancy is issued subject to the following covenants and conditions being observed by the holder/holders:
(a)	Not to erect or build or permit to be erected or built on the Land hereby granted any building other than those covenanted to be erected by virtue of this Certificate of Occupancy and the regulations under the said Act not to make or permit to be made any addition or alteration to the said buildings to be erected except in accordance with plans and specifications approved by the Anambra State Urban Development Board of the Anambra State of Nigeria or any other officer appointed by the board.
(b)	To keep the exterior and interior of the buildings to be erected and all outbuildings and erections which may at any time during the term hereby created be erected on the Land hereby granted and all additions to such buildings and outbuildings and the walls, fences and appurtenances thereof in good and tenantable repair and condition. 
(c)	Not to use the buildings on the said land whether now erected or to be erected here after thereon for any purpose other than that FOR WHICH THE LAND WAS GRANTED.
(d)	Not to alienate the right of Certificate of Occupancy hereby granted or any part thereof by sale, assignment, mortgage, transfer of possession, sublease or bequest or otherwise howsoever without the consent of the GOVERNOR first having been obtained.
(e)	Not to permit anything to be used or done upon any part of the granted premises which shall be noxious, noisy or offensive or be of any inconvenience or annoyance to tenants or occupiers of premises adjoining or near thereto.
(f)	To maintain standards of accommodation and sanitary and living conditions conformable with standards obtaining in the
neighbourhood.
(g)	To pay forthwith or without demand to the DIRECTOR OF LANDS or other persons appointed by him before the issue of this certificate, all survey fees, registration fees, the improvement premium specified above and other charges due in respect of preparation and issue and registration of this certificate.
(h)	To Install and operate water home sewage system within six months from the date the buildings erected on the plot are connected to a piped water-supply.
(i)	To pay with or without demand within the month of January each year the annual rent (specified above) reserved in these presents or as may be revised in future.

', 'b713632b-59e7-49a9-ab92-361c13801695', 1, 'i', 'test', '2016-08-18 17:41:45.026');


ALTER TABLE lease_condition_template ENABLE TRIGGER ALL;

-- Completed on 2016-08-29 14:22:26

--
-- PostgreSQL database dump complete
--

