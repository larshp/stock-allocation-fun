CLASS zcl_stock_location_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_stock,
        storage_location TYPE mard-lgort,
        quantity         TYPE mard-labst,
      END OF ty_stock.
    TYPES ty_stocks TYPE STANDARD TABLE OF ty_stock WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation,
        storage_location   TYPE mard-lgort,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation.
    TYPES ty_reservations TYPE STANDARD TABLE OF ty_reservation WITH EMPTY KEY.

    METHODS calculate
      IMPORTING
        it_stock        TYPE ty_stocks
        it_reservations TYPE ty_reservations
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_repository=>ty_location_stocks.
ENDCLASS.

CLASS zcl_stock_location_qty_calc IMPLEMENTATION.

  METHOD calculate.
    DATA lt_stock TYPE ty_stocks.
    DATA lt_positive_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA lv_unassigned_reservation TYPE decfloat34.
    DATA lv_location_reservation TYPE decfloat34.
    DATA lv_available_quantity TYPE decfloat34.
    DATA lv_location_balance TYPE decfloat34.
    DATA lv_outstanding_quantity TYPE decfloat34.
    DATA lv_deduction TYPE decfloat34.

    lt_stock = it_stock.
    SORT lt_stock BY storage_location.

    LOOP AT it_reservations INTO DATA(ls_reservation).
      lv_outstanding_quantity = CONV decfloat34(
        ls_reservation-required_quantity )
        - CONV decfloat34( ls_reservation-withdrawn_quantity ).
      IF lv_outstanding_quantity > 0.
        IF ls_reservation-storage_location IS INITIAL.
          lv_unassigned_reservation = lv_unassigned_reservation
            + lv_outstanding_quantity.
        ELSE.
          READ TABLE lt_stock TRANSPORTING NO FIELDS
            WITH KEY storage_location = ls_reservation-storage_location.
          IF sy-subrc <> 0.
            lv_unassigned_reservation = lv_unassigned_reservation
              + lv_outstanding_quantity.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_stock INTO DATA(ls_stock).
      IF ls_stock-storage_location IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR lv_location_reservation.
      LOOP AT it_reservations INTO ls_reservation
        WHERE storage_location = ls_stock-storage_location.
        lv_outstanding_quantity = CONV decfloat34(
          ls_reservation-required_quantity )
          - CONV decfloat34( ls_reservation-withdrawn_quantity ).
        IF lv_outstanding_quantity > 0.
          lv_location_reservation = lv_location_reservation
            + lv_outstanding_quantity.
        ENDIF.
      ENDLOOP.

      lv_location_balance = ls_stock-quantity - lv_location_reservation.
      IF lv_location_balance < 0.
        lv_unassigned_reservation = lv_unassigned_reservation
          - lv_location_balance.
        CLEAR lv_location_balance.
      ENDIF.

      IF lv_location_balance > 0.
        APPEND VALUE #(
          storage_location   = ls_stock-storage_location
          available_quantity = lv_location_balance )
          TO lt_positive_location_stock.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_positive_location_stock INTO DATA(ls_available_stock).
      lv_available_quantity = ls_available_stock-available_quantity.
      IF lv_unassigned_reservation > 0.
        IF lv_unassigned_reservation < lv_available_quantity.
          lv_deduction = lv_unassigned_reservation.
        ELSE.
          lv_deduction = lv_available_quantity.
        ENDIF.
        lv_available_quantity = lv_available_quantity - lv_deduction.
        lv_unassigned_reservation = lv_unassigned_reservation - lv_deduction.
      ENDIF.

      IF lv_available_quantity > 0.
        APPEND VALUE #(
          storage_location   = ls_available_stock-storage_location
          available_quantity = lv_available_quantity ) TO rt_stock.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
