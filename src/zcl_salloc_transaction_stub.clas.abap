CLASS zcl_salloc_transaction_stub DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_transaction.
    METHODS was_begun RETURNING VALUE(rv_value) TYPE abap_bool.
    METHODS was_committed RETURNING VALUE(rv_value) TYPE abap_bool.
    METHODS was_rolled_back RETURNING VALUE(rv_value) TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_begun TYPE abap_bool.
    DATA mv_committed TYPE abap_bool.
    DATA mv_rolled_back TYPE abap_bool.
ENDCLASS.

CLASS zcl_salloc_transaction_stub IMPLEMENTATION.
  METHOD zif_salloc_transaction~begin.
    mv_begun = abap_true.
  ENDMETHOD.

  METHOD zif_salloc_transaction~commit.
    mv_committed = abap_true.
  ENDMETHOD.

  METHOD zif_salloc_transaction~rollback.
    mv_rolled_back = abap_true.
  ENDMETHOD.

  METHOD was_begun.
    rv_value = mv_begun.
  ENDMETHOD.

  METHOD was_committed.
    rv_value = mv_committed.
  ENDMETHOD.

  METHOD was_rolled_back.
    rv_value = mv_rolled_back.
  ENDMETHOD.
ENDCLASS.
