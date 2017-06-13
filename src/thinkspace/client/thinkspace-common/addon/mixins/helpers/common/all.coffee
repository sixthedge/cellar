import ember from 'ember'
import array from 'thinkspace-common/mixins/helpers/common/array'
import model from 'thinkspace-common/mixins/helpers/common/model'
import object from 'thinkspace-common/mixins/helpers/common/object'
import promise from 'thinkspace-common/mixins/helpers/common/promise'
import general from 'thinkspace-common/mixins/helpers/common/general'
import changeset from 'thinkspace-common/mixins/helpers/common/changeset'

export default ember.Mixin.create array, model, object, promise, general
