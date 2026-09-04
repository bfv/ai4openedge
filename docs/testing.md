## unit tests
unittests are placed next to the classes that are tested and get suffix `_UT`. Note that the execution of the unit test in the CI builds relies on the suffix being `_UT`. To standardize naming:

```
  @BeforeAll.
  method public void _BeforeAll():

  @BeforeEach.
  method public void _BeforeEach():
  
  @AfterEach.
  method public void AfterEach():
  
  @AfterAll.
  method public void AfterAll():
```
Note that `@Before`, `@Setup`, `@Teardown` and `@After` are deprecated in favor of the above mentioned.
The actual `@Test` method are, au contraire the regular guidelines concerning method names, in snake case. This is because the readability in the output in the CI builds vastly improves this way. The method name should describe the success scenario, f.e. `serialized_arrayobj_equal_to_template`. 