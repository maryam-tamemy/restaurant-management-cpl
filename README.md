# Restaurant Management System — Logic & Functional Programming

A dual-language restaurant management system built in Prolog and Haskell  
for CSEN 403 (Concepts of Programming Languages) at the German University in Cairo.

## Overview

This project implements a restaurant management backend across two tasks using  
two completely different programming paradigms — logic programming and functional programming.

---

## Task 1 — Prolog (Logic Programming)

**Reservation Scheduling & Supply Management**

Implemented constraint-based scheduling using a knowledge base of groups, staff, tables, recipes, and orders.

### What it does
- Validates staff-count constraints per day and time slot
- Schedules all groups across available days satisfying table capacity, time preference, and staff limits
- Aggregates ingredients needed per group per day
- Groups all required ingredients by reservation date
- Exports reservation schedule to `.csv`
- Exports daily shopping list to `.csv`

### Key Predicates
- `check_staff/3` — validates reservations don't exceed staff capacity
- `schedule_all_reservations/2` — generates a full valid schedule via backtracking
- `group_ingredients/2` — collects all ingredients needed for a group's orders
- `needed_ingredients/2` — aggregates ingredients across all reservations grouped by date
- `write_reservations_to_csv/2` — exports schedule
- `write_ingredients_to_csv/2` — exports shopping list

### How to Run
1. Install [SWI-Prolog](https://www.swi-prolog.org/)
2. Load the knowledge base: `:-consult('public_KB.pl')`
3. Run queries directly in the SWI-Prolog console

---

## Task 2 — Haskell (Functional Programming)

**Supply Chain & Expense Management**

Implemented using custom algebraic data types (ADTs) and higher-order functions.  
WinHugs / GHC compatible.

### What it does
- Calculates delivery dates for ingredients across month boundaries
- Summarises all deliveries grouped and sorted by date with ingredient quantities
- Constructs a nested expense tree (Category/Item structure)
- Ranks most frequently ordered dishes
- Computes total expenses from a recursive expense tree
- Counts items under any named category subtree

### Key Functions
- `calculateDeliveryDates` — maps ingredients to their required delivery dates
- `summarizeAllDeliveries` — groups deliveries by date, sorted alphabetically
- `getDeliveryExpenses` — builds a `Category "Food Supplies" [Item ...]` tree
- `mostPopularDish` — returns all dishes tied for most orders
- `calculateTotalExpenses` — sums all leaf values using higher-order functions
- `countCategoryItems` — counts leaf nodes under a named subtree

### How to Run
1. Install [GHC](https://www.haskell.org/ghc/) or open in WinHugs
2. Load the file: `:load Restaurant.hs`
3. Call functions directly in GHCi

---

## Tech Stack
Prolog · Haskell · Logic Programming · Functional Programming · ADTs · Higher-Order Functions · CSV I/O

## Files
- `task1.pl` — Prolog implementation
- `task2.hs` — Haskell implementation
- `sample_KB.pl` — Small knowledge base for testing
- `public_KB.pl` — Full knowledge base used for grading
- `Public_Test_Cases.xlsx` — Public test cases for the Haskell task (Task 2)

## Author
Maryam Tamemy — GUC Spring 2026
