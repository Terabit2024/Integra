# Integra

Extension AL (PTE) për Microsoft Dynamics 365 Business Central që pranon porosi shitjeje nga sisteme të jashtme përmes një API-je të dedikuar dhe i kthen ato në Sales Orders reale në BC.

## Si funksionon

1. Sistemi i jashtëm dërgon porosinë (header + linja) me një **POST** te API-ja `salesOrders` — porosia ruhet në **Integra Sales Order Inbox**.
2. Me **POST** te aksioni `Microsoft.NAV.process` porosia procesohet menjëherë: krijohet klienti nëse s'ekziston, artikujt gjenden sipas fushës **No. 2**, emri i salesperson-it kthehet në kod nga tabela *Salespeople/Purchasers*.
3. Me **GET** lexohet rezultati: `status` = *Processed* (me `createdSalesOrderNo`) ose *Error* (me `errorMessage` në rreshtin e inbox-it).

Rregulla kryesore:

- `itemNo` në linja duhet të përputhet me **No. 2** të artikullit në BC (jo me No. e brendshëm).
- `salesperson` është emri i plotë i salesperson-it, saktësisht siç është regjistruar në BC.
- `externalDocumentNo` duhet të jetë unik — ridërgimi i të njëjtës porosi refuzohet me gabim (mbrojtje nga dublikatat).
- Hyrjet me gabim ruhen të plota (header + linja) me gabimin në rresht: mund të **editohen** direkt në listë/linja (ose me PATCH nga API) dhe të riprocesohen me *Process*; ose të fshihen me aksionin **Delete Entry** / `DELETE /salesOrders({id})`. Hyrjet e procesuara janë read-only dhe nuk fshihen (ruhen si histori e kontrollit të dublikatave).

## Struktura

- `src/SalesOrders/` — tabelat e inbox-it, faqet e listës dhe procesori (codeunit) që krijon Sales Orders.
- `src/Api/` — faqet API (`salesOrders`, `salesOrderLines`) nën `api/integra/integration/v1.0`.
- `src/Integration/` — setup-i i integrimit (grupet default të postimit për klientët e rinj).
- `postman/` — koleksioni Postman me shembullin e plotë *Create + Process Sales Order* për programerin e jashtëm.
- `scripts/Publish-Production.ps1` — publikimi në BC Cloud përmes Automation API (përdoret edhe nga CI).

## Publikimi

Çdo push në `main` e nis workflow-in **Publish to BC Production** (`.github/workflows/publish-production.yml`): kompilon paketën me `alc`, e ngarkon në mjedisin *Production* dhe pret statusin e deployment-it. Versioni merr numrin e run-it si segment të katërt. Aplikacioni Entra që përdor CI duhet të ketë në BC permission set-et **INTEGRA - ALL**, **EXTEN. MGT. - ADMIN** dhe një set bazë (p.sh. *D365 FULL ACCESS*).
