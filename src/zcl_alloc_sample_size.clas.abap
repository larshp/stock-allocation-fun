CLASS zcl_alloc_sample_size DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_rule,
             from_lot TYPE i,
             sample   TYPE i,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    METHODS sample_size
      IMPORTING
        it_rules         TYPE ty_rule_tt
        iv_lot_size      TYPE i
      RETURNING
        VALUE(rv_sample) TYPE i.

    METHODS covers_lot
      IMPORTING
        it_rules      TYPE ty_rule_tt
        iv_lot_size   TYPE i
      RETURNING
        VALUE(rv_any) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_sample_size IMPLEMENTATION.

  METHOD sample_size.
    DATA lv_best_from TYPE i.

    IF iv_lot_size <= 0.
      RETURN.
    ENDIF.

    " The rule with the highest lower bound that the lot still reaches wins, so
    " the table does not have to be sorted and overlapping rules resolve sensibly.
    LOOP AT it_rules INTO DATA(ls_rule).
      IF ls_rule-from_lot > iv_lot_size OR ls_rule-sample <= 0.
        CONTINUE.
      ENDIF.

      IF rv_sample = 0 OR ls_rule-from_lot > lv_best_from.
        rv_sample = ls_rule-sample.
        lv_best_from = ls_rule-from_lot.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD covers_lot.
    rv_any = xsdbool( sample_size( it_rules    = it_rules
                                   iv_lot_size = iv_lot_size ) > 0 ).
  ENDMETHOD.

ENDCLASS.
