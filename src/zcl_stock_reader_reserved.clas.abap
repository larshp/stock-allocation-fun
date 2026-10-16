CLASS zcl_stock_reader_reserved DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS constructor
      IMPORTING
        io_reader     TYPE REF TO zif_stock_reader
        io_commitment TYPE REF TO zcl_stock_commitment OPTIONAL.

  PRIVATE SECTION.
    DATA mo_reader     TYPE REF TO zif_stock_reader.
    DATA mo_commitment TYPE REF TO zcl_stock_commitment.

ENDCLASS.


CLASS zcl_stock_reader_reserved IMPLEMENTATION.

  METHOD constructor.
    mo_reader = io_reader.
    IF io_commitment IS SUPPLIED.
      mo_commitment = io_commitment.
    ENDIF.
    IF mo_commitment IS NOT BOUND.
      mo_commitment = NEW zcl_stock_commitment( ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_reader~read_stock.
    DATA lt_open TYPE zcl_stock_commitment=>ty_open_tt.
    DATA ls_open TYPE zcl_stock_commitment=>ty_open.

    rt_stock = mo_reader->read_stock( iv_matnr = iv_matnr
                                      iv_werks = iv_werks ).

    lt_open = mo_commitment->read_open( iv_matnr = iv_matnr
                                        iv_werks = iv_werks ).

    IF lt_open IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT rt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
      CLEAR ls_open.
      READ TABLE lt_open INTO ls_open WITH KEY lgort = <ls_stock>-lgort.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <ls_stock>-unrestricted_qty = <ls_stock>-unrestricted_qty - ls_open-qty.
      IF <ls_stock>-unrestricted_qty < 0.
        CLEAR <ls_stock>-unrestricted_qty.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
