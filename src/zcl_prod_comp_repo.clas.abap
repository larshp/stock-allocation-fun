CLASS zcl_prod_comp_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prod_comp_repo.
ENDCLASS.

CLASS zcl_prod_comp_repo IMPLEMENTATION.

  METHOD zif_prod_comp_repo~get_components.
    SELECT aufnr AS production_order,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           bwart AS movement_type,
           bdter AS required_date,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity,
           meins AS unit,
           xloek AS is_deleted,
           kzear AS is_final_issue
      FROM resb
      WHERE aufnr = @iv_production_order
      ORDER BY rsnum, rspos
      INTO CORRESPONDING FIELDS OF TABLE @rt_items.
  ENDMETHOD.

ENDCLASS.
