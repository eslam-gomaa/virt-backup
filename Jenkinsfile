def ubuntu_16_04 = addEmbeddableBadgeConfiguration(id: "ubuntu_16_04", style: "flat", subject: "Test Result")
def ubuntu_18_04 = addEmbeddableBadgeConfiguration(id: "ubuntu_18_04", style: "flat", subject: "Test Result")
def ubuntu_20_04 = addEmbeddableBadgeConfiguration(id: "ubuntu_20_04", style: "flat", subject: "Test Result")
def centos_7 = addEmbeddableBadgeConfiguration(id: "centos_7", style: "flat", subject: "Test Result")
def centos_8 = addEmbeddableBadgeConfiguration(id: "centos_8", style: "flat", subject: "Test Result")
def fedora34 = addEmbeddableBadgeConfiguration(id: "fedora34", style: "flat", subject: "Test Result")
def debian10 = addEmbeddableBadgeConfiguration(id: "debian10", style: "flat", subject: "Test Result")
def debian11 = addEmbeddableBadgeConfiguration(id: "debian11", style: "flat", subject: "Test Result")

pipeline {
  agent { label 'kvm_lab' }
  stages {
    stage('Clone') {
      steps {
        git(url: 'https://github.com/eslam-gomaa/virt-backup.git', branch: 'master', credentialsId: 'github_id')
      }
    }
    stage('Post clone step') {
      steps {
        script {
          echo "Changing the owner & permissions of .vagrant directory"
          // Avoid Permission denied when executing 'git clean -fdx' (Removes .vagrant directory)
          sh '''
            if [ ! -d .vagrant ]
            then
                mkdir -p .vagrant
                chown $(whoami):$(whoami) .vagrant -R
                chmod +s .vagrant -R
                setfacl -m d:u:$(whoami):rwx .vagrant/
                setfacl -m u:$(whoami):rwx .vagrant/
            fi     
          '''
        }
      }
    }
    stage('Destroy old test VMs') {
      steps {
        script {
          echo "Double check that old test vm's are cleared"
          sh '''
              for i in $(virsh list --all --name)
              do
                virsh destroy "$i"
                virsh undefine "$i"
                virsh vol-delete --pool default "$i".img
              done
          '''
          sh 'vagrant destroy -f'
        }
      }
    }
    stage('Download boxs that don\'t exist') {
      steps {
        // Add any new box here to download it before running the tests
        // to prevent a BUG that may prevent downloading the box from within the pipeline.
        script {
          sh '''
          for image_name in "generic/ubuntu1804" "generic/ubuntu1604" "generic/ubuntu2004" "generic/centos8" "generic/centos7" "generic/fedora34"  "generic/debian10" "generic/debian11"
          do
              if ! vagrant box list | grep $image_name >/dev/null
              then
                  echo "Downloading $image_name"
                  vagrant box add $image_name --provider libvirt  --no-tty
              fi
          done          
          '''
        }
      }
    }
    
    stage('Test Ubuntu 18.04') {
      steps {
        script {
          ubuntu_18_04.setStatus('running')
          try {
            echo 'Begin Testing'
            sh 'vagrant up ubuntu_18_04'
            ubuntu_18_04.setStatus('passed')
            ubuntu_18_04.setColor('brightgreen')
          } catch (Exception err) {
            ubuntu_18_04.setStatus('failed')
            ubuntu_18_04.setColor('pink')
            // error "Build failed"
            }
          echo 'Removing the test vm'
          sh 'vagrant destroy -f ubuntu_18_04'
        }
      }
    }
    stage('Test Ubuntu 16.04') {
      steps {
        script {
          ubuntu_16_04.setStatus('running')
          try {
            echo 'Begin Testing'
            sh 'vagrant up ubuntu_16_04'
            ubuntu_16_04.setStatus('passed')
            ubuntu_16_04.setColor('brightgreen')
          } catch (Exception err) {
            ubuntu_16_04.setStatus('failed')
            ubuntu_16_04.setColor('pink')
            // error "Build failed"
            }
          echo 'Removing the test vm'
          sh 'vagrant destroy -f ubuntu_16_04'
        }
      }
    }
    stage('Test Ubuntu 20.04') {
      steps {
        script {
          ubuntu_20_04.setStatus('running')
          try {
            echo 'Begin Testing'
            sh 'vagrant up ubuntu_20_04'
            ubuntu_20_04.setStatus('passed')
            ubuntu_20_04.setColor('brightgreen')
          } catch (Exception err) {
            ubuntu_20_04.setStatus('failed')
            ubuntu_20_04.setColor('pink')
            // error "Build failed"
            }
          echo 'Removing the test vm'
          sh 'vagrant destroy -f ubuntu_20_04'
        }
      }
    }
    stage('Post pipeline: clear cached vagrant boxes') {
      steps {
        script {
          echo "Useful to save disk space"
          sh '''
            for i in $(find home/orange/.vagrant.d/boxes/ -size +600M  2>/dev/null)
            do
              rm "$i" -f
            done
          '''
        }
      }
    }
  }
}