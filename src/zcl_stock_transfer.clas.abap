CLASS zcl_stock_transfer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_proposal,
             matnr        TYPE matnr,
             source_werks TYPE werks_d,
             target_werks TYPE werks_d,
             needed_qty   TYPE menge_d,
             target_qty   TYPE menge_d,
             source_qty   TYPE menge_d,
             transfer_qty TYPE menge_d,
             shortage_qty TYPE menge_d,
           END OF ty_proposal.

    METHODS constructor
      IMPORTING
        io_stock_reader TYPE REF TO zif_stock_reader
        is_policy       TYPE zcl_stock_allocator=>ty_policy OPTIONAL.

    METHODS available
      IMPORTING
        iv_matnr           TYPE matnr
        iv_werks           TYPE werks_d
      RETURNING
        VALUE(rv_quantity) TYPE menge_d.

    METHODS propose
      IMPORTING
        iv_matnr           TYPE matnr
        iv_source_werks    TYPE werks_d
        iv_target_werks    TYPE werks_d
        iv_needed_qty      TYPE menge_d
      RETURNING
        VALUE(rs_proposal) TYPE ty_proposal.

  PRIVATE SECTION.
    DATA mo_allocator TYPE REF TO zcl_stock_allocator.

ENDCLASS.


CLASS zcl_stock_transfer IMPLEMENTATION.

  METHOD constructor.
    IF is_policy IS SUPPLIED.
      mo_allocator = NEW zcl_stock_allocator( io_stock_reader = io_stock_reader
                                              is_policy       = is_policy ).
    ELSE.
      mo_allocator = NEW zcl_stock_allocator( io_stock_reader = io_stock_reader ).
    ENDIF.
  ENDMETHOD.

  METHOD available.
    rv_quantity = mo_allocator->available_quantity( iv_matnr = iv_matnr
                                                    iv_werks = iv_werks ).
  ENDMETHOD.

  METHOD propose.
    DATA lv_gap TYPE menge_d.

    rs_proposal-matnr = iv_matnr.
    rs_proposal-source_werks = iv_source_werks.
    rs_proposal-target_werks = iv_target_werks.
    rs_proposal-needed_qty = iv_needed_qty.
    rs_proposal-target_qty = available( iv_matnr = iv_matnr
                                        iv_werks = iv_target_werks ).
    rs_proposal-source_qty = available( iv_matnr = iv_matnr
                                        iv_werks = iv_source_werks ).

    IF rs_proposal-target_qty >= iv_needed_qty.
      " the target plant can serve the demand on its own
      RETURN.
    ENDIF.

    lv_gap = iv_needed_qty - rs_proposal-target_qty.

    IF rs_proposal-source_qty < lv_gap.
      rs_proposal-transfer_qty = rs_proposal-source_qty.
    ELSE.
      rs_proposal-transfer_qty = lv_gap.
    ENDIF.

    rs_proposal-shortage_qty = lv_gap - rs_proposal-transfer_qty.
  ENDMETHOD.

ENDCLASS.
