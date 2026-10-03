CLASS zcl_stock_batch_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_stock,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        expiration_date  TYPE mcha-vfdat,
        quantity         TYPE mchb-clabs,
      END OF ty_stock.
    TYPES ty_stocks TYPE STANDARD TABLE OF ty_stock WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
        specificity        TYPE i,
      END OF ty_reservation.
    TYPES ty_reservations TYPE STANDARD TABLE OF ty_reservation WITH EMPTY KEY.

    METHODS calculate
      IMPORTING
        it_stock        TYPE ty_stocks
        it_reservations TYPE ty_reservations
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_repository=>ty_batch_stocks.
ENDCLASS.

CLASS zcl_stock_batch_qty_calc IMPLEMENTATION.

  METHOD calculate.
    DATA lt_stock TYPE ty_stocks.
    DATA lt_reservations TYPE ty_reservations.
    DATA lv_outstanding TYPE mchb-clabs.
    DATA lv_deduction TYPE mchb-clabs.

    lt_stock = it_stock.
    SORT lt_stock BY storage_location batch.
    LOOP AT it_reservations INTO DATA(ls_input_reservation).
      DATA(ls_ordered_reservation) = ls_input_reservation.
      IF ls_input_reservation-storage_location IS NOT INITIAL
          AND ls_input_reservation-batch IS NOT INITIAL.
        ls_ordered_reservation-specificity = 1.
      ELSEIF ls_input_reservation-storage_location IS INITIAL
          AND ls_input_reservation-batch IS INITIAL.
        ls_ordered_reservation-specificity = 3.
      ELSE.
        ls_ordered_reservation-specificity = 2.
      ENDIF.
      APPEND ls_ordered_reservation TO lt_reservations.
    ENDLOOP.
    SORT lt_reservations BY specificity storage_location batch.

    "Apply reservations to matching stock first; blank location/batch values
    "match all balances. Over-reserved demand then reduces remaining stock in
    "stable location/batch order to avoid presenting an inflated free total.
    LOOP AT lt_reservations INTO DATA(ls_reservation).
      lv_outstanding = ls_reservation-required_quantity
        - ls_reservation-withdrawn_quantity.
      IF lv_outstanding <= 0.
        CONTINUE.
      ENDIF.

      LOOP AT lt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
        IF ls_reservation-storage_location IS NOT INITIAL
            AND <ls_stock>-storage_location
              <> ls_reservation-storage_location.
          CONTINUE.
        ENDIF.
        IF ls_reservation-batch IS NOT INITIAL
            AND <ls_stock>-batch <> ls_reservation-batch.
          CONTINUE.
        ENDIF.
        IF lv_outstanding <= 0.
          EXIT.
        ENDIF.
        IF <ls_stock>-quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_outstanding < <ls_stock>-quantity.
          lv_deduction = lv_outstanding.
        ELSE.
          lv_deduction = <ls_stock>-quantity.
        ENDIF.
        <ls_stock>-quantity = <ls_stock>-quantity - lv_deduction.
        lv_outstanding = lv_outstanding - lv_deduction.
      ENDLOOP.

      IF lv_outstanding > 0.
        LOOP AT lt_stock ASSIGNING <ls_stock>.
          IF lv_outstanding <= 0.
            EXIT.
          ENDIF.
          IF <ls_stock>-quantity <= 0.
            CONTINUE.
          ENDIF.
          IF lv_outstanding < <ls_stock>-quantity.
            lv_deduction = lv_outstanding.
          ELSE.
            lv_deduction = <ls_stock>-quantity.
          ENDIF.
          <ls_stock>-quantity = <ls_stock>-quantity - lv_deduction.
          lv_outstanding = lv_outstanding - lv_deduction.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_stock INTO DATA(ls_stock).
      IF ls_stock-quantity > 0
          AND ls_stock-storage_location IS NOT INITIAL
          AND ls_stock-batch IS NOT INITIAL.
        APPEND VALUE #(
          storage_location   = ls_stock-storage_location
          batch              = ls_stock-batch
          expiration_date    = ls_stock-expiration_date
          available_quantity = ls_stock-quantity ) TO rt_stock.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
