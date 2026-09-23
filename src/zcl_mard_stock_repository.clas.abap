CLASS zcl_mard_stock_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
ENDCLASS.

CLASS zcl_mard_stock_repository IMPLEMENTATION.

  METHOD zif_stock_repository~get_unrestricted_stock.
    DATA lv_unrestricted_quantity TYPE mard-labst.
    DATA lv_reserved_quantity TYPE resb-bdmng.
    DATA lv_withdrawn_quantity TYPE resb-enmng.

    SELECT SUM( labst )
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @lv_unrestricted_quantity.

    SELECT SUM( bdmng ), SUM( enmng )
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO ( @lv_reserved_quantity, @lv_withdrawn_quantity ).

    lv_reserved_quantity = lv_reserved_quantity
      - lv_withdrawn_quantity.
    rv_quantity = NEW zcl_stock_avail_qty_calc( )->calculate(
      iv_unrestricted_quantity = lv_unrestricted_quantity
      iv_reserved_quantity     = lv_reserved_quantity ).
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    SELECT SINGLE eisbe
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @rv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    TYPES:
      BEGIN OF ty_reservation_total,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        item_number        TYPE resb-kdpos,
        schedule_line      TYPE resb-kdein,
        requirement_date   TYPE resb-bdter,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_total.
    DATA lt_reservation_totals TYPE STANDARD TABLE OF
      ty_reservation_total WITH EMPTY KEY.

    SELECT matnr AS material,
           werks AS plant,
           kdpos AS item_number,
           kdein AS schedule_line,
           bdter AS requirement_date,
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      WHERE kdauf = @iv_sales_document
        AND bwart = '231'
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY matnr, werks, kdpos, kdein, bdter
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_totals.

    LOOP AT lt_reservation_totals INTO DATA(ls_reservation_total).
      DATA(lv_open_quantity) = ls_reservation_total-required_quantity
        - ls_reservation_total-withdrawn_quantity.
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material         = ls_reservation_total-material
        plant            = ls_reservation_total-plant
        item_number      = ls_reservation_total-item_number
        schedule_line    = ls_reservation_total-schedule_line
        requirement_date = ls_reservation_total-requirement_date
        open_quantity    = lv_open_quantity ) TO rt_reservations.
    ENDLOOP.
    SORT rt_reservations BY item_number material plant schedule_line
      requirement_date.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    DATA lv_required_quantity TYPE resb-bdmng.
    DATA lv_withdrawn_quantity TYPE resb-enmng.
    DATA lo_stock_quantity_calculator TYPE REF TO zcl_stock_avail_qty_calc.

    SELECT SUM( labst ) AS unrestricted_quantity,
           SUM( insme ) AS quality_inspection_quantity,
           SUM( speme ) AS blocked_quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO CORRESPONDING FIELDS OF @rs_status.

    SELECT SUM( bdmng ), SUM( enmng )
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO ( @lv_required_quantity, @lv_withdrawn_quantity ).

    rs_status-reserved_quantity = lv_required_quantity
      - lv_withdrawn_quantity.
    IF rs_status-reserved_quantity < 0.
      CLEAR rs_status-reserved_quantity.
    ENDIF.
    SELECT SINGLE eisbe
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @rs_status-safety_stock_quantity.
    lo_stock_quantity_calculator = NEW zcl_stock_avail_qty_calc( ).
    rs_status-available_unrestricted_qty =
      lo_stock_quantity_calculator->calculate(
        iv_unrestricted_quantity = rs_status-unrestricted_quantity
        iv_reserved_quantity     = rs_status-reserved_quantity ).
    rs_status-available_after_safety_qty =
      lo_stock_quantity_calculator->calculate_with_safety_stock(
        iv_available_quantity    = rs_status-available_unrestricted_qty
        iv_safety_stock_quantity = rs_status-safety_stock_quantity ).
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    DATA lt_stock TYPE zcl_stock_location_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_location_qty_calc=>ty_reservations.
    DATA lt_available_stock TYPE zif_stock_repository=>ty_location_stocks.

    SELECT lgort AS storage_location,
           SUM( labst ) AS unrestricted_quantity,
           SUM( insme ) AS quality_inspection_qty,
           SUM( speme ) AS blocked_quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort
      INTO CORRESPONDING FIELDS OF TABLE @rt_status.

    LOOP AT rt_status INTO DATA(ls_stock_status).
      APPEND VALUE #(
        storage_location = ls_stock_status-storage_location
        quantity         = ls_stock_status-unrestricted_quantity )
        TO lt_stock.
    ENDLOOP.

    SELECT lgort AS storage_location,
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY lgort
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.

    lt_available_stock = NEW zcl_stock_location_qty_calc( )->calculate(
      it_stock        = lt_stock
      it_reservations = lt_reservations ).
    LOOP AT rt_status ASSIGNING FIELD-SYMBOL(<ls_stock_status>).
      READ TABLE lt_available_stock INTO DATA(ls_available_stock)
        WITH KEY storage_location = <ls_stock_status>-storage_location.
      IF sy-subrc = 0.
        <ls_stock_status>-available_unrestricted_qty =
          ls_available_stock-available_quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
    DATA lt_stock TYPE zcl_stock_location_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_location_qty_calc=>ty_reservations.

    SELECT lgort, SUM( labst ) AS quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock.

    SELECT lgort,
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY lgort
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.

    rt_stock = NEW zcl_stock_location_qty_calc( )->calculate(
      it_stock        = lt_stock
      it_reservations = lt_reservations ).
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    DATA(lt_batch_status) = me->zif_stock_repository~get_stock_status_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    LOOP AT lt_batch_status INTO DATA(ls_batch_status).
      IF ls_batch_status-available_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        storage_location   = ls_batch_status-storage_location
        batch              = ls_batch_status-batch
        expiration_date    = ls_batch_status-expiration_date
        available_quantity = ls_batch_status-available_quantity ) TO rt_stock.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    DATA lt_stock TYPE zcl_stock_batch_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_batch_qty_calc=>ty_reservations.
    DATA lt_available_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA lt_plant_batches TYPE STANDARD TABLE OF mcha WITH DEFAULT KEY.
    DATA lt_global_batches TYPE STANDARD TABLE OF mch1 WITH DEFAULT KEY.
    DATA lv_available_quantity TYPE mchb-clabs.

    SELECT lgort, charg, SUM( clabs ) AS quantity
      FROM mchb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort, charg
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock.

    SELECT charg, vfdat
      FROM mcha
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_plant_batches.

    SELECT charg, vfdat
      FROM mch1
      WHERE matnr = @iv_material
      INTO CORRESPONDING FIELDS OF TABLE @lt_global_batches.

    LOOP AT lt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
      READ TABLE lt_plant_batches INTO DATA(ls_plant_batch)
        WITH KEY charg = <ls_stock>-batch.
      IF sy-subrc = 0 AND ls_plant_batch-vfdat IS NOT INITIAL.
        <ls_stock>-expiration_date = ls_plant_batch-vfdat.
      ELSE.
        READ TABLE lt_global_batches INTO DATA(ls_global_batch)
          WITH KEY charg = <ls_stock>-batch.
        IF sy-subrc = 0.
          <ls_stock>-expiration_date = ls_global_batch-vfdat.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SELECT lgort, charg,
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY lgort, charg
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.

    lt_available_stock = NEW zcl_stock_batch_qty_calc( )->calculate(
      it_stock        = lt_stock
      it_reservations = lt_reservations ).

    LOOP AT lt_stock INTO DATA(ls_stock).
      CLEAR lv_available_quantity.
      READ TABLE lt_available_stock INTO DATA(ls_available_stock)
        WITH KEY storage_location = ls_stock-storage_location
                 batch            = ls_stock-batch.
      IF sy-subrc = 0.
        lv_available_quantity = ls_available_stock-available_quantity.
      ENDIF.
      APPEND VALUE #(
        storage_location      = ls_stock-storage_location
        batch                 = ls_stock-batch
        expiration_date       = ls_stock-expiration_date
        unrestricted_quantity = ls_stock-quantity
        available_quantity    = lv_available_quantity ) TO rt_status.
    ENDLOOP.
    SORT rt_status BY storage_location batch.
  ENDMETHOD.

ENDCLASS.
