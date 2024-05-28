
const jsonDoc = '''
  <document>
    <recordSound id='10001'>
      
    </recordSound>  
  </document>''';

const jsonSingleLine = '''
  <document>
    <table id='10001'>
      <row>
        <cell>
          <single >1Stand Alone Complex,single alone.</single>
        </cell>
        <cell>
          <single >2Stand Alone Complex,single alone.</single>
        </cell>
        <cell>
          <single >3Stand Alone Complex,single alone.</single>
        </cell>
      </row>
      <row>
        <cell>
          <single >4Stand Alone Complex,single alone.</single>
        </cell>
        <cell>
          <single >5Stand Alone Complex,single alone.</single>
        </cell>
        <cell>
          <single >6Stand Alone Complex,single alone.</single>
        </cell>
      </row>
      <row>
        <cell>
          <single >7Stand Alone Complex,single alone.</single>
        </cell>
        <cell>
          <single >8Stand Alone Complex,single alone.</single>
        </cell>
        <cell>
          <single >9Stand Alone Complex,single alone.</single>
        </cell>
      </row>
    </table> 
  </document>''';


const jsonDocBack1 = '''
  <document>
    <single id="10001" cIds="10003">
      <single >Stand Alone Complex,single alone.</single>
    </single>  
    <image id="10003" pid="10001" cIds="10005">
    </image>
    <step id="10005" cIds="10006" pid="10003">
      <stepItem>
        <name><single bold="true" size = "20">New Dinahview</single></name>
        <detail><single color="grey">Id laboriosam excepturi. Sint eos quis cupiditate. Voluptatem autem consequatur neque quos ex quia excepturi. Quia odit aliquam et sed. Odit accusamus cumque ut.</single></detail>
      </stepItem>
      <stepItem>
        <name><single bold="true">North Colton</single></name>
        <detail><single color="grey">Impedit corporis cumque vel illo quasi autem. Ut deserunt magnam velit quasi. Dolores ipsa fugiat ipsam delectus earum dolores autem. Omnis ut debitis consequatur magnam. Dolorum eos voluptatem.</single></detail>
      </stepItem>
      <stepItem>
        <name><single bold="true">Doyleview</single></name>
        <detail><single color="grey">Iusto sint est eius ut ea. Qui rerum dicta reiciendis. Ratione tempora debitis ipsam dignissimos quod ipsa. Sapiente dolorem provident fugit ea.</single></detail>
      </stepItem>
    </step>
    <step id="10006" pid="10005">
      <stepItem>
        <name><single bold="true">Murphyfurt</single></name>
        <detail><single color="grey">Totam tenetur voluptatem aperiam eaque. Dolorum ut officia et nihil tenetur. Fugiat totam minus.</single></detail>
      </stepItem>
    </step>
  </document>
''';



const jsonDocBack = '''
  <document>
    <singleLine id="10001" cIds="10002,10003">
      <single >Stand Alone Complex,single alone.</single>
    </singleLine>  
    <image id="10003" pid="10001">
    </image>
    <singleLine id="10002" cIds="10005" pid="10001">
      <single>Corporate Integration</single>
    </singleLine>
    <step id="10005" cIds="10006" pid="10002">
      <stepItem>
        <name><single bold="true" size = "20">New Dinahview</single></name>
        <detail><single color="grey">Id laboriosam excepturi. Sint eos quis cupiditate. Voluptatem autem consequatur neque quos ex quia excepturi. Quia odit aliquam et sed. Odit accusamus cumque ut.</single></detail>
      </stepItem>
      <stepItem>
        <name><single bold="true">North Colton</single></name>
        <detail><single color="grey">Impedit corporis cumque vel illo quasi autem. Ut deserunt magnam velit quasi. Dolores ipsa fugiat ipsam delectus earum dolores autem. Omnis ut debitis consequatur magnam. Dolorum eos voluptatem.</single></detail>
      </stepItem>
      <stepItem>
        <name><single bold="true">Doyleview</single></name>
        <detail><single color="grey">Iusto sint est eius ut ea. Qui rerum dicta reiciendis. Ratione tempora debitis ipsam dignissimos quod ipsa. Sapiente dolorem provident fugit ea.</single></detail>
      </stepItem>
    </step>
    <step id="10006" pid="10005">
      <stepItem>
        <name><single bold="true">Murphyfurt</single></name>
        <detail><single color="grey">Totam tenetur voluptatem aperiam eaque. Dolorum ut officia et nihil tenetur. Fugiat totam minus.</single></detail>
      </stepItem>
    </step>
  </document>
''';

