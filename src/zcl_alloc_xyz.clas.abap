CLASS zcl_alloc_xyz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             mean     TYPE i,
             std_dev  TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS classify
      IMPORTING
        is_item         TYPE ty_item
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS class_of
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_material     TYPE matnr
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS is_stable
      IMPORTING
        iv_class     TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_xyz IMPLEMENTATION.

  METHOD classify.
    DATA lv_variation TYPE i.

    " A demand spread beyond half its mean is erratic; within a quarter, stable.
    IF is_item-mean <= 0.
      rv_class = 'Z'.
      RETURN.
    ENDIF.

    lv_variation = is_item-std_dev * 100 DIV is_item-mean.

    IF lv_variation <= 25.
      rv_class = 'X'.
    ELSEIF lv_variation <= 50.
      rv_class = 'Y'.
    ELSE.
      rv_class = 'Z'.
    ENDIF.
  ENDMETHOD.

  METHOD class_of.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material = iv_material.
        rv_class = classify( ls_item ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_stable.
    " Only the X class is counted as stable demand.
    rv_ok = xsdbool( iv_class = 'X' ).
  ENDMETHOD.

ENDCLASS.
