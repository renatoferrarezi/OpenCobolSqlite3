       IDENTIFICATION DIVISION.
       PROGRAM-ID. sqlite.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
      *     CONSOLE IS CRT.
           CRT STATUS IS SCREEN-STATUS.
           DECIMAL-POINT IS COMMA.

       DATA DIVISION.
       WORKING-STORAGE SECTION.


       78  K-ESCAPE      VALUE 2012.
       01  SCREEN-STATUS PIC 9(4).

       
       01 SQLCA-FILENAME               PIC X(100).
       01 SQLCA-QUERY                  PIC X(1000).
       01 SQLCA-ERROR                  PIC x(6).
       01 SQLCA-ERROR-MESSAGE          PIC X(255).
       01 SQLCA_CUR_STAT               PIC 9(8) COMP-3 VALUE ZERO.
       01 SQLCA-CID                    USAGE POINTER.
       01 SQLCA-STATEMENT              USAGE POINTER.
    
       01  REGISTRO.
           05 W-ID                         PIC 9(6).
           05 W-NOME                       PIC X(100).
           05 W-PRECO                      PIC 9(6)V99 VALUE 150,22.

      * COPY color-book.
        PROCEDURE DIVISION.

       050-INICIALIZA.
           MOVE 150,22 TO W-PRECO.
           MOVE "teste.db" TO SQLCA-FILENAME.

           CALL "sqliteConnect" USING BY REFERENCE  SQLCA-CID
                                                    SQLCA-FILENAME
                                                    SQLCA-ERROR
                                                    SQLCA-ERROR-MESSAGE.

           STRING "select id, name, price " DELIMITED BY SIZE 
                  "from cars" DELIMITED BY SIZE 
           INTO SQLCA-QUERY.

           CALL "sqliteOpenCursor" USING BY REFERENCE 
                                                    SQLCA-CID
                                                    SQLCA-QUERY
                                                    SQLCA-STATEMENT
                                                    SQLCA-ERROR
                                                    SQLCA-ERROR-MESSAGE.

           PERFORM 060-GET-RESULT UNTIL SQLCA_CUR_STAT = 1.

           STOP RUN.


       060-GET-RESULT.
           CALL "sqlitefetch" USING BY REFERENCE SQLCA-STATEMENT
                                                 SQLCA_CUR_STAT
                                                 W-ID
                                                 W-NOME
                                                 W-PRECO.
           IF SQLCA_CUR_STAT EQUAL 0 THEN 
               DISPLAY "ID:"
               DISPLAY W-ID
               DISPLAY "NOME:"
               DISPLAY W-NOME
               DISPLAY "PRECO"
               DISPLAY W-PRECO
            END-IF.
