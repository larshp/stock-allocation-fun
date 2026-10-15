CLASS zcl_alloc_sshp_tour DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS order
      IMPORTING
        it_stops        TYPE zcl_alloc_bin_distance=>ty_coord_tt
      RETURNING
        VALUE(rt_order) TYPE zcl_alloc_bin_distance=>ty_coord_tt.

ENDCLASS.


CLASS zcl_alloc_sshp_tour IMPLEMENTATION.

  METHOD order.
    DATA lt_aisles TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    " S-shape: visit one aisle after the other in ascending order, taking every
    " stop in an aisle before moving on, which is how a wide-aisle warehouse is
    " picked in one sweep.
    LOOP AT it_stops INTO DATA(ls_stop).
      READ TABLE lt_aisles TRANSPORTING NO FIELDS
        WITH KEY table_line = ls_stop-aisle.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      APPEND ls_stop-aisle TO lt_aisles.
    ENDLOOP.

    SORT lt_aisles ASCENDING.

    LOOP AT lt_aisles INTO DATA(lv_aisle).
      LOOP AT it_stops INTO DATA(ls_again).
        IF ls_again-aisle = lv_aisle.
          APPEND ls_again TO rt_order.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
