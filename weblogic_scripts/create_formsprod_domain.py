# ============================================================
# Create WebLogic 14.1.2 Domain: formsprod
# V2.2 - modeled directly from V2
# ============================================================

selectTemplate('Basic WebLogic Server Domain')
loadTemplates()

setOption('DomainName', 'formsprod')
setOption('OverwriteDomain', 'true')

# ============================================================
# AdminServer
# ============================================================

cd('/Servers/AdminServer')
set('ListenAddress', '')
set('ListenPort', 7001)

# Admin credentials
cd('/Security/base_domain/User/weblogic')
cmo.setPassword('Welcome1!')

# ============================================================
# Machine + Node Manager
# ============================================================

cd('/')
create('app02Machine', 'Machine')

cd('/Machines/app02Machine')
create('app02Machine', 'NodeManager')

cd('/Machines/app02Machine/NodeManager/app02Machine')
set('ListenAddress', '10.20.2.27')
set('ListenPort', 5556)
set('NMType', 'SSL')

# ============================================================
# WLS_FORMS Managed Server
# ============================================================

cd('/')
create('WLS_FORMS', 'Server')

cd('/Servers/WLS_FORMS')
set('ListenAddress', '')
set('ListenPort', 9001)
set('Machine', 'app02Machine')

# ServerStart block - same pattern as V2
cd('/Servers/WLS_FORMS')
create('WLS_FORMS', 'ServerStart')

cd('/Servers/WLS_FORMS/ServerStart/WLS_FORMS')
set('Arguments', '-Xms256m -Xmx512m')

# ============================================================
# WLS_REPORTS Managed Server
# ============================================================

cd('/')
create('WLS_REPORTS', 'Server')

cd('/Servers/WLS_REPORTS')
set('ListenAddress', '')
set('ListenPort', 9002)
set('Machine', 'app02Machine')

# ServerStart block - same pattern as V2
cd('/Servers/WLS_REPORTS')
create('WLS_REPORTS', 'ServerStart')

cd('/Servers/WLS_REPORTS/ServerStart/WLS_REPORTS')
set('Arguments', '-Xms256m -Xmx512m')

# ============================================================
# Write domain
# ============================================================

writeDomain('/u01/app/oracle/config/domains/formsprod')
closeTemplate()

print('============================================================')
print('formsprod V2.2 domain created successfully.')
print('AdminServer : 7001')
print('WLS_FORMS   : 9001')
print('WLS_REPORTS : 9002')
print('Node Manager: 5556')
print('============================================================')
[oracle@app02 ~]$
