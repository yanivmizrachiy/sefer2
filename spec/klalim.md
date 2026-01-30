# klalim — כללים ודרישות מחייבים

Repository: **sefer2**

## עקרונות יסוד
- GitHub הוא מקור האמת.
- אין דמו: כל מה שמופיע באתר מבוסס קבצים אמיתיים בריפו.
- נתונים נשמרים ב-CSV (data/*.csv).
- כל שינוי מתועד ב-commit.

## קישורים
- אתר: https://yanivmizrachiy.github.io/sefer2/

## מצב קיים (מתעדכן תמיד)
- קבצי נתונים:
  - data/grades.csv (שכבות)
  - data/groups.csv (קבוצות + מורים)
  - data/students.csv (תלמידים — כרגע שלד)
- אתר (site/):
  - site/index.html (דף ראשי)
  - site/grades/*.html (דפי שכבות)
  - site/groups/*.html (דפי קבוצות)
  - site/teachers/index.html + site/teachers/*.html (דפי מורים)
  - site/klalim.html (תצוגת כללים + מצב)

## כלל עבודה חשוב
כל יצירה/שינוי עתידי חייב לעדכן גם את הסעיף 'מצב קיים' כאן.

## מצב מערכת (מתעדכן)
עודכן: 2026-01-30 08:46

### האתר
- Pages: https://yanivmizrachiy.github.io/sefer2/

### תיקיות מקור אמת
- spec/klalim.md (מסמך מחייב)
- data/ (נתונים)
- site/ (האתר)

### דפים מרכזיים באתר
- / (דף בית)
- /grades/z.html /grades/h.html /grades/t.html
- /teachers/
- /klalim.html

## עבודה מרובת מכשירים (ענן בלבד)
- GitHub הוא מקור האמת היחיד. אין תלות בשום מחשב/טלפון.
- עובדים מכל מכשיר ע״י Pull/Push או gh api בלבד – אבל התוצאה תמיד נשמרת בענן (main).
- לא מערבבים ריפואים ולא מערבבים שיחות: כל שינוי חייב להיות בריפו הזה בלבד: yanivmizrachiy/sefer2.
- כל פריסה מתבצעת דרך GitHub Actions / Pages של הריפו.
- אם מכשיר נתקע/נסגר – ממשיכים ממכשיר אחר בלי “לעשות הכל מהתחלה”.


## תיעוד חובה (Journal + Decisions)
- כל פעולה/ניסוי/הצלחה/כשל – מתועדים ב-`spec/journal.md`.
- החלטות מערכתיות “שאי אפשר לשכוח” – מתועדות ב-`spec/decisions.md`.
- אסור להשאיר ידע רק בצ’אט. המסמכים בריפו הם האמת.

- [יומן עבודה](journal.md)
- [החלטות](decisions.md)
