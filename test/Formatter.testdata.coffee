module.exports =
  fixDuplicateUnorderedListSiblingsInput: """
<div class="pageSection">
  <div class="pageSectionHeader">
    <h2 class="pageSectionTitle">Pages:</h2>
  </div>
  <ul>
    <li>
      <a href="#">A0</a>
      <ul>
        <li>
          <a href="#">B1</a>
          <ul>
            <li>
              <a href="#">C1</a>
            </li>
          </ul>
          <ul>
            <li>
              <a href="#">C2</a>
              <ul>
                <li>
                  <a href="#">D1</a>
                </li>
              </ul>
            </li>
          </ul>
          <ul>
            <li>
              <a href="#">C3</a>
            </li>
          </ul>
          <ul>
            <li>
              <a href="#">C4</a>
            </li>
          </ul>
          <ul>
            <li>
              <a href="#">C5</a>
            </li>
          </ul>
        </li>
      </ul>
      <ul>
        <li>
          <a href="#">B2</a>
        </li>
      </ul>
      <ul>
        <li>
          <a href="#">B3</a>
          <ul>
            <li>
              <a href="#">C6</a>
            </li>
          </ul>
          <ul>
            <li>
              <a href="#">C7</a>
            </li>
          </ul>
        </li>
      </ul>
      <ul>
        <li>
          <a href="#">B4</a>
        </li>
      </ul>
    </li>
  </ul>
</div>
"""

  fixDuplicateUnorderedListSiblingsExpected: """
<div class="pageSection"><div class="pageSectionHeader"><h2 class="pageSectionTitle">Pages:</h2></div><ul><li><a href="#">A0</a><ul><li><a href="#">B1</a><ul><li><a href="#">C1</a></li><li><a href="#">C2</a><ul><li><a href="#">D1</a></li></ul></li><li><a href="#">C3</a></li><li><a href="#">C4</a></li><li><a href="#">C5</a></li></ul></li><li><a href="#">B2</a></li><li><a href="#">B3</a><ul><li><a href="#">C6</a></li><li><a href="#">C7</a></li></ul></li><li><a href="#">B4</a></li></ul></li></ul></div>
"""
