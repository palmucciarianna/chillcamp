# ChillCamp / ChillChamp — specifica iniziale

Questo documento riguarda esclusivamente l'app multiplayer di minigiochi ChillCamp/ChillChamp.

## Funzionalità concordate

1. Login Google per identificare gli utenti.
2. Gruppi privati con codice univoco d'invito valido 24 ore; solo il creatore può modificare il gruppo.
3. Almeno 2 giocatori per gruppo.
4. Competizioni della durata di 21 giorni, con un minigioco diverso ogni giorno.
5. Regole dei tentativi: una prova e due tentativi; un terzo tentativo è previsto soltanto per l'ultimo giocatore, secondo le regole concordate.
6. Dieci minigiochi nella prima versione.
7. Tema chiaro/scuro.
8. Stile Basic/Chill selezionabile.
9. Niente suoni né vibrazioni.
10. Funzionalità online con Firebase e obiettivo multipiattaforma iOS + Android.

## Approccio tecnico

- Prima prova: progetto Android nativo in Kotlin, creato con Android Studio e predisposto per Firebase.
- Direzione proposta per il progetto multipiattaforma: Flutter + Dart, con Firebase per autenticazione e backend.
- Il primo ZIP va conservato come prototipo di riferimento, non cancellato. Non è però il codice condiviso iOS/Android: le parti utili potranno essere replicate o adattate nel nuovo progetto.
- Ambiente dell'utente: MacBook Air M2. Android Studio è installato ma non era ancora stato aperto durante la prima configurazione; Firebase non era ancora stato configurato.

## Sequenza di lavoro proposta

1. Aprire ed eseguire il prototipo Android per verificare che cosa contiene davvero.
2. Conservare una copia originale e versionarla con Git.
3. Creare il progetto Flutter condiviso per iOS e Android.
4. Implementare e testare prima struttura dell'app, gruppi e flusso dei minigiochi.
5. Collegare Firebase e completare autenticazione, dati condivisi e regole di accesso.
6. Testare Android; successivamente configurare e testare la build iOS con Xcode.

## Nota sullo ZIP originale

Lo ZIP iniziale citato nella conversazione precedente si chiamava `ChillChamp-Android-source.zip`. Il file binario originale non è allegato a questa conversazione, quindi questo documento non lo sostituisce. Per riutilizzare esattamente quella versione, recuperare lo ZIP dalla chat in cui è stato generato e caricarlo qui.
