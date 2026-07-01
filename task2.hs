
daysInMonth :: Month -> Int -> Int
daysInMonth Jan _ = 31
daysInMonth Feb y = if (mod y 4 == 0 && mod y 100 /= 0) || mod y 400 == 0 then 29 else 28
daysInMonth Mar _ = 31
daysInMonth Apr _ = 30
daysInMonth May _ = 31
daysInMonth Jun _ = 30
daysInMonth Jul _ = 31
daysInMonth Aug _ = 31
daysInMonth Sep _ = 30
daysInMonth Oct _ = 31
daysInMonth Nov _ = 30
daysInMonth Dec _ = 31

-- 
prevMonth :: Month -> (Month, Bool)
prevMonth Jan = (Dec, True)
prevMonth Feb = (Jan, False)
prevMonth Mar = (Feb, False)
prevMonth Apr = (Mar, False)
prevMonth May = (Apr, False)
prevMonth Jun = (May, False)
prevMonth Jul = (Jun, False)
prevMonth Aug = (Jul, False)
prevMonth Sep = (Aug, False)
prevMonth Oct = (Sep, False)
prevMonth Nov = (Oct, False)
prevMonth Dec = (Nov, False)


subtractDays :: Date -> Int -> Date
subtractDays (d, m, y) n
    | n <= 0 = (d, m, y)
    | d > n  = (d - n, m, y)
    | otherwise =
        let (pm, yearBack) = prevMonth m
            newYear        = if yearBack then y - 1 else y
            daysInPm       = daysInMonth pm newYear
        in subtractDays (daysInPm, pm, newYear) (n - d)

--  
flattenIngredients :: Ingredient -> [String]
flattenIngredients (SimpleIngredient name)   = [name]
flattenIngredients (Recipe _ subIngredients) = concatMap flattenIngredients subIngredients

-- a) calculateDeliveryDates 
calculateDeliveryDates :: Date -> [Ingredient] -> [(Date, (String, Price))]
calculateDeliveryDates requiredDate ingredients =
    [ (subtractDays requiredDate days, (name, price))
    | name <- concatMap flattenIngredients ingredients
    , (iName, days, price) <- ingredient_info
    , iName == name ]




monthToInt :: Month -> Int
monthToInt Jan = 1
monthToInt Feb = 2
monthToInt Mar = 3
monthToInt Apr = 4
monthToInt May = 5
monthToInt Jun = 6
monthToInt Jul = 7
monthToInt Aug = 8
monthToInt Sep = 9
monthToInt Oct = 10
monthToInt Nov = 11
monthToInt Dec = 12


dateEarlier :: Date -> Date -> Bool
dateEarlier (d1, m1, y1) (d2, m2, y2)
    | y1 /= y2 = y1 < y2
    | monthToInt m1 /= monthToInt m2 = monthToInt m1 < monthToInt m2
    | otherwise = d1 < d2


sortByDate :: [Delivery] -> [Delivery]
sortByDate [] = []
sortByDate (x:xs) = insertDelivery x (sortByDate xs)

insertDelivery :: Delivery -> [Delivery] -> [Delivery]
insertDelivery d [] = [d]
insertDelivery d@(date1, _) (x@(date2, _) : xs)
    | dateEarlier date1 date2 = d : x : xs
    | otherwise               = x : insertDelivery d xs


sameDate :: Date -> Date -> Bool
sameDate (d1, m1, y1) (d2, m2, y2) = d1 == d2 && m1 == m2 && y1 == y2


sortStrings :: [Supply] -> [Supply]
sortStrings [] = []
sortStrings (x:xs) = insertSupply x (sortStrings xs)

insertSupply :: Supply -> [Supply] -> [Supply]
insertSupply s [] = [s]
insertSupply s@(n1, _, _) (x@(n2, _, _) : xs)
    | n1 <= n2  = s : x : xs
    | otherwise = x : insertSupply s xs


mergeSupplies :: [Supply] -> [Supply]
mergeSupplies [] = []
mergeSupplies ((name, qty, price) : rest) =
    let same    = filter (\(n, _, _) -> n == name) rest
        others  = filter (\(n, _, _) -> n /= name) rest
        totalQ  = qty + sum (map (\(_, q, _) -> q) same)
        totalP  = price + sum (map (\(_, _, p) -> p) same)
    in (name, totalQ, totalP) : mergeSupplies others

groupByDate :: [(Date, String, Price)] -> [Delivery]
groupByDate [] = []
groupByDate ((date, name, price) : rest) =
    let same   = filter (\(d, _, _) -> sameDate d date) rest
        others = filter (\(d, _, _) -> not (sameDate d date)) rest
        allSupplies = (name, 1, price) : map (\(_, n, p) -> (n, 1, p)) same
        merged      = mergeSupplies allSupplies
        sorted      = sortStrings merged
    in (date, sorted) : groupByDate others

--b) summarizeAllDeliveries 
summarizeAllDeliveries :: [Date] -> [Delivery]
summarizeAllDeliveries dates =
    let relevant  = filter (\(date, _) -> elem date dates) shopping_list
        flat      = [ (delivDate, name, price)
                    | (reqDate, ingredients) <- relevant
                    , (delivDate, (name, price)) <- calculateDeliveryDates reqDate ingredients ]
        grouped   = groupByDate flat
    in sortByDate grouped

--c) getDeliveryExpenses 
getDeliveryExpenses :: [Delivery] -> Expense
getDeliveryExpenses deliveries =
    Category "Food Supplies" (concatMap makeItems deliveries)

makeItems :: Delivery -> [Expense]
makeItems (date, supplies) = map (\(name, _, price) -> Item name price date) supplies

--d) mostPopularDish 
countOccurrences :: String -> [String] -> Int
countOccurrences dish orders = length (filter (== dish) orders)

removeDuplicates :: [String] -> [String]
removeDuplicates [] = []
removeDuplicates (x:xs) = x : removeDuplicates (filter (/= x) xs)

mostPopularDish :: [String] -> [String]
mostPopularDish [] = []
mostPopularDish orders =
    let unique   = removeDuplicates orders
        counts   = map (\d -> (d, countOccurrences d orders)) unique
        maxCount = maximum (map snd counts)
    in map fst (filter (\(_, c) -> c == maxCount) counts)

--e) calculateTotalExpenses
calculateTotalExpenses :: Expense -> Price
calculateTotalExpenses (Item _ price _)      = price
calculateTotalExpenses (Category _ expenses) = foldr (\e acc -> calculateTotalExpenses e + acc) 0 expenses




countLeaves :: Expense -> Int
countLeaves (Item _ _ _)        = 1
countLeaves (Category _ expenses) = foldr (\e acc -> countLeaves e + acc) 0 expenses

--f) countCategoryItems 
countCategoryItems :: String -> Expense -> Int
countCategoryItems target (Item _ _ _) = 0
countCategoryItems target (Category name expenses)
    | name == target = countLeaves (Category name expenses)
    | otherwise      = foldr (\e acc -> countCategoryItems target e + acc) 0 expenses