CLASS zcl_stock_batch_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_stock,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        valuation_type   TYPE mcha-bwtar,
        expiration_date  TYPE mcha-vfdat,
        expiry_source    TYPE c LENGTH 1,
        quantity         TYPE mchb-clabs,
      END OF ty_stock.
    TYPES ty_stocks TYPE STANDARD TABLE OF ty_stock WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation,
        reservation_number  TYPE resb-rsnum,
        reservation_item    TYPE resb-rspos,
        required_date       TYPE resb-bdter,
        storage_location    TYPE mard-lgort,
        batch               TYPE mchb-charg,
        valuation_type      TYPE mcha-bwtar,
        required_quantity   TYPE resb-bdmng,
        withdrawn_quantity  TYPE resb-enmng,
        specificity         TYPE i,
        input_sequence      TYPE i,
        allocation_sequence TYPE i,
      END OF ty_reservation.
    TYPES ty_reservations TYPE STANDARD TABLE OF ty_reservation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_calculation_result,
        stocks                         TYPE zif_stock_repository=>ty_batch_stocks,
        matched_allocation_quantity    TYPE resb-bdmng,
        fallback_allocation_quantity   TYPE resb-bdmng,
        matched_allocation_row_count   TYPE i,
        fallback_allocation_row_count  TYPE i,
        fully_allocated_resv_count     TYPE i,
        partially_allocated_resv_count TYPE i,
        unallocated_resv_count         TYPE i,
        fully_alloc_resv_open_qty      TYPE resb-bdmng,
        part_alloc_resv_open_qty       TYPE resb-bdmng,
        unalloc_resv_open_qty          TYPE resb-bdmng,
        uncovered_reservation_quantity TYPE resb-bdmng,
        uncovered_reservation_keys     TYPE zif_stock_repository=>ty_reservation_keys,
        uncovered_reservations         TYPE zif_stock_repository=>ty_uncovered_reservations,
        resv_allocation_summaries      TYPE
          zif_stock_repository=>ty_reservation_allocation_summaries,
        allocation_details             TYPE zif_stock_repository=>ty_batch_allocation_details,
      END OF ty_calculation_result.

    METHODS calculate
      IMPORTING
        it_stock        TYPE ty_stocks
        it_reservations TYPE ty_reservations
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_repository=>ty_batch_stocks.

    METHODS calculate_with_summary
      IMPORTING
        it_stock         TYPE ty_stocks
        it_reservations  TYPE ty_reservations
      RETURNING
        VALUE(rs_result) TYPE ty_calculation_result.
ENDCLASS.

CLASS zcl_stock_batch_qty_calc IMPLEMENTATION.

  METHOD calculate.
    DATA(ls_result) = calculate_with_summary(
      it_stock        = it_stock
      it_reservations = it_reservations ).
    rt_stock = ls_result-stocks.
  ENDMETHOD.

  METHOD calculate_with_summary.
    DATA lt_stock TYPE ty_stocks.
    DATA lt_reservations TYPE ty_reservations.
    DATA lv_outstanding TYPE decfloat34.
    DATA lv_open_quantity TYPE decfloat34.
    DATA lv_matched_quantity TYPE decfloat34.
    DATA lv_fallback_quantity TYPE decfloat34.
    DATA lv_deduction TYPE decfloat34.
    DATA lv_negative_stock TYPE decfloat34.
    DATA lv_available_quantity TYPE decfloat34.
    DATA lv_input_sequence TYPE i.
    DATA lv_allocation_sequence TYPE i.
    DATA lv_allocation_outcome TYPE c LENGTH 1.

    lt_stock = it_stock.
    SORT lt_stock STABLE BY storage_location batch valuation_type
      expiration_date.
    LOOP AT it_reservations INTO DATA(ls_input_reservation).
      DATA(ls_ordered_reservation) = ls_input_reservation.
      ADD 1 TO lv_input_sequence.
      ls_ordered_reservation-input_sequence = lv_input_sequence.
      CLEAR ls_ordered_reservation-allocation_sequence.
      ls_ordered_reservation-specificity = 3.
      IF ls_input_reservation-storage_location IS NOT INITIAL.
        ls_ordered_reservation-specificity -= 1.
      ENDIF.
      IF ls_input_reservation-batch IS NOT INITIAL.
        ls_ordered_reservation-specificity -= 1.
      ENDIF.
      IF ls_input_reservation-valuation_type IS NOT INITIAL.
        ls_ordered_reservation-specificity -= 1.
      ENDIF.
      APPEND ls_ordered_reservation TO lt_reservations.
    ENDLOOP.
    SORT lt_reservations BY specificity storage_location batch
      valuation_type input_sequence.

    "Apply reservations to matching stock first; blank selectors match all
    "balances. Valuation-type shortages stay within that valuation bucket.
    LOOP AT lt_reservations INTO DATA(ls_reservation).
      lv_open_quantity = CONV decfloat34(
        ls_reservation-required_quantity )
        - CONV decfloat34( ls_reservation-withdrawn_quantity ).
      lv_outstanding = lv_open_quantity.
      CLEAR: lv_matched_quantity, lv_fallback_quantity.
      IF lv_outstanding <= 0.
        CONTINUE.
      ENDIF.
      ADD 1 TO lv_allocation_sequence.
      ls_reservation-allocation_sequence = lv_allocation_sequence.

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
        IF ls_reservation-valuation_type IS NOT INITIAL
            AND <ls_stock>-valuation_type
              <> ls_reservation-valuation_type.
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
        IF ls_reservation-reservation_number IS NOT INITIAL
            AND ls_reservation-reservation_item IS NOT INITIAL.
          APPEND VALUE #(
            reservation_number         = ls_reservation-reservation_number
            reservation_item           = ls_reservation-reservation_item
            allocation_sequence        =
              ls_reservation-allocation_sequence
            required_date              = ls_reservation-required_date
            allocation_pass            =
              zif_stock_repository=>c_allocation_pass_match
            requested_storage_location = ls_reservation-storage_location
            requested_batch            = ls_reservation-batch
            requested_valuation_type   = ls_reservation-valuation_type
            storage_location           = <ls_stock>-storage_location
            batch                      = <ls_stock>-batch
            valuation_type             = <ls_stock>-valuation_type
            expiration_date            = <ls_stock>-expiration_date
            expiration_date_source     =
              <ls_stock>-expiry_source
            quantity                   = lv_deduction )
            TO rs_result-allocation_details.
          ADD 1 TO rs_result-matched_allocation_row_count.
        ENDIF.
        <ls_stock>-quantity = <ls_stock>-quantity - lv_deduction.
        lv_outstanding = lv_outstanding - lv_deduction.
        lv_matched_quantity += lv_deduction.
        rs_result-matched_allocation_quantity += lv_deduction.
      ENDLOOP.

      IF lv_outstanding > 0.
        LOOP AT lt_stock ASSIGNING <ls_stock>.
          IF lv_outstanding <= 0.
            EXIT.
          ENDIF.
          IF ls_reservation-valuation_type IS NOT INITIAL
              AND <ls_stock>-valuation_type
                <> ls_reservation-valuation_type.
            CONTINUE.
          ENDIF.
          IF <ls_stock>-quantity <= 0.
            CONTINUE.
          ENDIF.
          IF lv_outstanding < <ls_stock>-quantity.
            lv_deduction = lv_outstanding.
          ELSE.
            lv_deduction = <ls_stock>-quantity.
          ENDIF.
          IF ls_reservation-reservation_number IS NOT INITIAL
              AND ls_reservation-reservation_item IS NOT INITIAL.
            APPEND VALUE #(
              reservation_number         = ls_reservation-reservation_number
              reservation_item           = ls_reservation-reservation_item
              allocation_sequence        =
                ls_reservation-allocation_sequence
              required_date              = ls_reservation-required_date
              allocation_pass            =
                zif_stock_repository=>c_allocation_pass_fallback
              requested_storage_location = ls_reservation-storage_location
              requested_batch            = ls_reservation-batch
              requested_valuation_type   = ls_reservation-valuation_type
              storage_location           = <ls_stock>-storage_location
              batch                      = <ls_stock>-batch
              valuation_type             = <ls_stock>-valuation_type
              expiration_date            = <ls_stock>-expiration_date
              expiration_date_source     =
                <ls_stock>-expiry_source
              quantity                   = lv_deduction )
              TO rs_result-allocation_details.
            ADD 1 TO rs_result-fallback_allocation_row_count.
          ENDIF.
          <ls_stock>-quantity = <ls_stock>-quantity - lv_deduction.
          lv_outstanding = lv_outstanding - lv_deduction.
          lv_fallback_quantity += lv_deduction.
          rs_result-fallback_allocation_quantity += lv_deduction.
        ENDLOOP.
      ENDIF.
      CLEAR lv_allocation_outcome.
      IF lv_outstanding > 0.
        IF lv_open_quantity > lv_outstanding.
          ADD 1 TO rs_result-partially_allocated_resv_count.
          rs_result-part_alloc_resv_open_qty += lv_open_quantity.
          lv_allocation_outcome =
            zif_stock_repository=>c_allocation_outcome_partial.
        ELSE.
          ADD 1 TO rs_result-unallocated_resv_count.
          rs_result-unalloc_resv_open_qty += lv_open_quantity.
          lv_allocation_outcome =
            zif_stock_repository=>c_allocation_outcome_none.
        ENDIF.
        rs_result-uncovered_reservation_quantity += lv_outstanding.
        IF ls_reservation-reservation_number IS NOT INITIAL
            AND ls_reservation-reservation_item IS NOT INITIAL.
          APPEND VALUE #(
            reservation_number = ls_reservation-reservation_number
            reservation_item   = ls_reservation-reservation_item )
            TO rs_result-uncovered_reservation_keys.
          APPEND VALUE #(
            reservation_number      = ls_reservation-reservation_number
            reservation_item        = ls_reservation-reservation_item
            allocation_sequence     = ls_reservation-allocation_sequence
            required_date           = ls_reservation-required_date
            storage_location        = ls_reservation-storage_location
            batch                   = ls_reservation-batch
            valuation_type          = ls_reservation-valuation_type
            required_quantity       = ls_reservation-required_quantity
            withdrawn_quantity      = ls_reservation-withdrawn_quantity
            open_quantity           = lv_open_quantity
            allocated_quantity      = lv_open_quantity - lv_outstanding
            matched_quantity        = lv_matched_quantity
            fallback_quantity       = lv_fallback_quantity
            uncovered_quantity      = lv_outstanding
            allocation_coverage_pct =
              ( CONV decfloat34( lv_matched_quantity )
                + CONV decfloat34( lv_fallback_quantity ) )
              * 100 / CONV decfloat34( lv_open_quantity )
            allocation_shortage_pct =
              CONV decfloat34( lv_outstanding )
              * 100 / CONV decfloat34( lv_open_quantity )
            matched_share_pct       =
              CONV decfloat34( lv_matched_quantity )
              * 100 / CONV decfloat34( lv_open_quantity )
            fallback_share_pct      =
              CONV decfloat34( lv_fallback_quantity )
              * 100 / CONV decfloat34( lv_open_quantity ) )
            TO rs_result-uncovered_reservations.
        ENDIF.
      ELSE.
        ADD 1 TO rs_result-fully_allocated_resv_count.
        rs_result-fully_alloc_resv_open_qty += lv_open_quantity.
        lv_allocation_outcome =
          zif_stock_repository=>c_allocation_outcome_full.
      ENDIF.
      IF ls_reservation-reservation_number IS NOT INITIAL
          AND ls_reservation-reservation_item IS NOT INITIAL.
        APPEND VALUE #(
          reservation_number         = ls_reservation-reservation_number
          reservation_item           = ls_reservation-reservation_item
          allocation_sequence        = ls_reservation-allocation_sequence
          required_date              = ls_reservation-required_date
          requested_storage_location = ls_reservation-storage_location
          requested_batch            = ls_reservation-batch
          requested_valuation_type   = ls_reservation-valuation_type
          required_quantity          = ls_reservation-required_quantity
          withdrawn_quantity         = ls_reservation-withdrawn_quantity
          open_quantity              = lv_open_quantity
          allocated_quantity         = lv_open_quantity - lv_outstanding
          matched_quantity           = lv_matched_quantity
          fallback_quantity          = lv_fallback_quantity
          uncovered_quantity         = lv_outstanding
          allocation_outcome         = lv_allocation_outcome
          allocation_coverage_pct    =
            ( CONV decfloat34( lv_matched_quantity )
              + CONV decfloat34( lv_fallback_quantity ) )
            * 100 / CONV decfloat34( lv_open_quantity )
          allocation_shortage_pct    =
            CONV decfloat34( lv_outstanding )
            * 100 / CONV decfloat34( lv_open_quantity )
          matched_share_pct          =
            CONV decfloat34( lv_matched_quantity )
            * 100 / CONV decfloat34( lv_open_quantity )
          fallback_share_pct         =
            CONV decfloat34( lv_fallback_quantity )
            * 100 / CONV decfloat34( lv_open_quantity ) )
          TO rs_result-resv_allocation_summaries.
      ENDIF.
    ENDLOOP.
    SORT rs_result-uncovered_reservation_keys
      BY reservation_number reservation_item.
    SORT rs_result-uncovered_reservations
      BY reservation_number reservation_item.
    SORT rs_result-resv_allocation_summaries
      BY reservation_number reservation_item.
    SORT rs_result-allocation_details STABLE
      BY reservation_number reservation_item.

    LOOP AT lt_stock INTO DATA(ls_negative_stock).
      IF ls_negative_stock-quantity < 0.
        lv_negative_stock = lv_negative_stock
          - ls_negative_stock-quantity.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_stock INTO DATA(ls_stock).
      IF ls_stock-quantity <= 0
          OR ls_stock-storage_location IS INITIAL
          OR ls_stock-batch IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_available_quantity = ls_stock-quantity.
      IF lv_negative_stock > 0.
        IF lv_negative_stock < lv_available_quantity.
          lv_deduction = lv_negative_stock.
        ELSE.
          lv_deduction = lv_available_quantity.
        ENDIF.
        lv_available_quantity = lv_available_quantity - lv_deduction.
        lv_negative_stock = lv_negative_stock - lv_deduction.
      ENDIF.

      IF lv_available_quantity > 0.
        APPEND VALUE #(
          storage_location   = ls_stock-storage_location
          batch              = ls_stock-batch
          valuation_type     = ls_stock-valuation_type
          expiration_date    = ls_stock-expiration_date
          available_quantity = lv_available_quantity ) TO rs_result-stocks.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
